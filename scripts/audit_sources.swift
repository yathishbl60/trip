import Foundation
import SwiftParser
import SwiftSyntax

let root = URL(fileURLWithPath: CommandLine.arguments[1])
let manager = FileManager.default
let files = ["trip", "TripWidgets", "Packages/TripKit/Sources", "Packages/TripKit/Tests", "Performance", "scripts"].flatMap { directory in
    manager.enumerator(at: root.appendingPathComponent(directory), includingPropertiesForKeys: nil)!
        .compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
} + [root.appendingPathComponent("Packages/TripKit/Package.swift")]
var issues: [String] = []
var members = 0
var views = 0
for file in files {
    let source = try String(contentsOf: file, encoding: .utf8)
    let lines = source.split(separator: "\n", omittingEmptySubsequences: false).count - (source.hasSuffix("\n") ? 1 : 0)
    if lines > 100 { issues.append("\(file.path): \(lines) physical lines") }
    let tree = Parser.parse(source: source)
    if tree.hasError { issues.append("Invalid Swift syntax: \(file.path)") }
    let forbidden = ["UIKit", "UIImage", "UIViewRepresentable", "UIViewControllerRepresentable"]
    if tree.tokens(viewMode: .sourceAccurate).contains(where: { token in
        if case let .identifier(name) = token.tokenKind { return forbidden.contains(name) }
        return false
    }) {
        issues.append("Forbidden UIKit usage: \(file.path)")
    }
    let audit = MemberAudit(tree, file: file.path)
    audit.walk(tree)
    issues += audit.errors
    members += audit.members
    if audit.views > 0 {
        views += 1
        if !source.contains("#Preview") { issues.append("Missing preview: \(file.path)") }
    }
}
let skills = manager.enumerator(at: root.appendingPathComponent(".agents/skills"), includingPropertiesForKeys: nil)!
var skillFiles = 0
for case let file as URL in skills where !file.hasDirectoryPath && file.lastPathComponent != ".DS_Store" {
    let source = try String(contentsOf: file, encoding: .utf8)
    let lines = source.split(separator: "\n", omittingEmptySubsequences: false).count - (source.hasSuffix("\n") ? 1 : 0)
    skillFiles += 1
    if lines > 50 { issues.append("\(file.path): \(lines) physical lines") }
}
for issue in issues { print(issue) }
print("Audited \(files.count) Swift files, \(members) members, \(views) view files, \(skillFiles) skill files.")
exit(issues.isEmpty ? 0 : 1)
