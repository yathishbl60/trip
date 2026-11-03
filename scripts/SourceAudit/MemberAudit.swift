import Foundation
import SwiftParser
import SwiftSyntax

final class MemberAudit: SyntaxVisitor {
    let converter: SourceLocationConverter
    var members = 0
    var views = 0
    var errors: [String] = []

    init(_ tree: SourceFileSyntax, file: String) {
        converter = SourceLocationConverter(fileName: file, tree: tree)
        super.init(viewMode: .sourceAccurate)
    }

    func check(_ node: some SyntaxProtocol) {
        members += 1
        let start = converter.location(for: node.positionAfterSkippingLeadingTrivia)
        let end = converter.location(for: node.endPositionBeforeTrailingTrivia)
        let count = end.line - start.line + 1
        if count > memberLimit(node, file: start.file) { errors.append("\(start.file):\(start.line): \(count) physical lines") }
    }

    private func memberLimit(_ node: some SyntaxProtocol, file: String) -> Int {
        // User-approved 2026-10-26: keep ten static App Shortcut declarations readable.
        guard file.hasSuffix("/trip/App/Intents/TripShortcuts.swift"),
              let declaration = node.as(VariableDeclSyntax.self), declaration.bindings.count == 1,
              declaration.bindings.first?.pattern.trimmedDescription == "appShortcuts",
              declaration.modifiers.contains(where: { $0.name.text == "static" }) else { return 20 }
        return 22
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        checkController(node)
        let protocols = ["View", "MapContent", "ToolbarContent", "ViewModifier", "ButtonStyle", "Shape"]
        if node.inheritanceClause?.inheritedTypes.contains(where: { protocols.contains($0.type.trimmedDescription) }) == true {
            views += 1
        }
        return .visitChildren
    }

    private func checkController(_ node: StructDeclSyntax) {
        guard node.name.text.hasSuffix("Controller") else { return }
        let variables = node.memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
        let stored = variables.flatMap(\.bindings).filter(isStored)
        let names = stored.map { $0.pattern.trimmedDescription }
        if names != ["model"] {
            let location = converter.location(for: node.positionAfterSkippingLeadingTrivia)
            errors.append("\(location.file):\(location.line): controller must store only its model")
        }
    }

    private func isStored(_ binding: PatternBindingSyntax) -> Bool {
        guard let block = binding.accessorBlock else { return true }
        switch block.accessors {
        case .getter: return false
        case .accessors(let accessors):
            return accessors.contains { ["willSet", "didSet"].contains($0.accessorSpecifier.text) }
        }
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.name.text.hasSuffix("Controller") {
            let location = converter.location(for: node.positionAfterSkippingLeadingTrivia)
            errors.append("\(location.file):\(location.line): controllers must be structs")
        }
        return .visitChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        check(node)
        return .visitChildren
    }

    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        check(node)
        return .visitChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.bindings.contains(where: { $0.accessorBlock != nil }) { check(node) }
        return .visitChildren
    }

    override func visit(_ node: SubscriptDeclSyntax) -> SyntaxVisitorContinueKind {
        check(node)
        return .visitChildren
    }
}
