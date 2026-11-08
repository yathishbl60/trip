import SwiftParser

let cases: [(String, String, Int, Int)] = [
    ("named", "#Preview(\"Ready\") { Text(\"Hi\") }", 1, 0),
    ("unnamed", "#Preview { Text(\"Hi\") }", 0, 1),
    ("traits only", "#Preview(traits: .landscapeLeft) { Text(\"Hi\") }", 0, 1),
    ("empty", "#Preview(\"   \") { Text(\"Hi\") }", 0, 1),
    ("comment", "// #Preview(\"Fake\") { EmptyView() }", 0, 0),
    ("string", "let text = \"#Preview\"", 0, 0),
    ("conditional", "#if DEBUG\n#Preview(\"Local\") { EmptyView() }\n#endif", 1, 0),
    ("duplicate", "#Preview(\"Same\") { A() }\n#Preview(\"Same\") { B() }", 2, 1)
]
for (name, source, count, errors) in cases {
    let tree = Parser.parse(source: source)
    let audit = PreviewAudit(tree, file: name)
    audit.walk(tree)
    precondition(audit.names.count == count, "\(name): unexpected preview count")
    precondition(audit.errors.count == errors, "\(name): unexpected diagnostics: \(audit.errors)")
}
print("Passed \(cases.count) syntax-aware preview checks.")
