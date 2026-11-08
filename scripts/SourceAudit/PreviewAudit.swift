import Foundation
import SwiftSyntax

/// Checks syntax and names; fixture isolation and rendered coverage need review.
final class PreviewAudit: SyntaxVisitor {
    let converter: SourceLocationConverter
    var names: [String] = []
    var errors: [String] = []

    init(_ tree: SourceFileSyntax, file: String) {
        converter = SourceLocationConverter(fileName: file, tree: tree)
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: MacroExpansionDeclSyntax) -> SyntaxVisitorContinueKind {
        record(node.macroName.text, arguments: node.arguments, position: node.positionAfterSkippingLeadingTrivia)
        return .visitChildren
    }

    override func visit(_ node: MacroExpansionExprSyntax) -> SyntaxVisitorContinueKind {
        record(node.macroName.text, arguments: node.arguments, position: node.positionAfterSkippingLeadingTrivia)
        return .visitChildren
    }

    private func record(_ macro: String, arguments: LabeledExprListSyntax, position: AbsolutePosition) {
        guard macro == "Preview" else { return }
        let location = converter.location(for: position)
        guard let literal = arguments.first?.expression.as(StringLiteralExprSyntax.self),
              !literal.segments.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errors.append("\(location.file):\(location.line): preview needs a descriptive name")
            return
        }
        let name = literal.segments.description
        if names.contains(name) { errors.append("\(location.file):\(location.line): duplicate preview name: \(name)") }
        names.append(name)
    }
}
