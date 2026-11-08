"""Regression cases for scoped visual policy, comments, previews, and geometry notes."""
from pathlib import Path
import tempfile
import unittest
from check_design_system import source_errors
from source_text import production_mask


class DesignPolicyChecks(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / 'Sources').mkdir()
        self.path = self.root / 'Sources/View.swift'
        self.policy = {'roots': ['Sources'], 'exceptions': {}, 'geometry_notes': {}}

    def errors(self, source):
        self.path.write_text(source)
        return source_errors(self.root, self.policy)[0]

    def test_preview_closure_is_excluded_but_later_production_is_checked(self):
        source = '''#Preview("local") {
    VStack { Text("}").padding(21) }
}
struct Later: View { var body: some View { Text("content").padding(22) } }
'''
        errors = self.errors(source)
        self.assertEqual(len(errors), 1)
        self.assertIn('View.swift:4:', errors[0])

    def test_strings_nested_comments_and_raw_strings_cannot_hide_code(self):
        source = '''// #Preview { .padding(80) }
/* first /* nested */ .padding(81) */
let hint = #"#Preview { .padding(82) }"#
struct Live: View { var body: some View { Text("hello").padding(23) } }
'''
        self.assertEqual(len(self.errors(source)), 1)
        self.assertEqual(production_mask(source).count('\n'), source.count('\n'))

    def test_exception_applies_only_to_exact_reviewed_occurrence_count(self):
        code = 'content.padding(23)'
        self.policy['exceptions'] = {'raw_inset': {'Sources/View.swift': {
            'reason': 'Specific map clearance', 'occurrences': [{'code': code, 'count': 1}]}}}
        self.assertEqual(self.errors(code + '\n'), [])
        self.assertEqual(len(self.errors(code + '\n' + code + '\n')), 1)
        errors = self.errors('content.padding(24)\n')
        self.assertTrue(any('Use a spacing token' in issue for issue in errors))
        self.assertTrue(any('unused design occurrence' in issue for issue in errors))

    def test_blanket_exemptions_and_missing_paths_are_rejected(self):
        self.policy['exceptions'] = {'raw_inset': {'Sources/View.swift': 'old blanket exemption'}}
        self.assertTrue(any('Invalid scoped' in issue for issue in self.errors('content.padding(23)')))
        self.policy['exceptions'] = {'raw_inset': {'missing.swift': {'reason': 'Missing', 'occurrences': []}}}
        self.assertTrue(any('Invalid scoped' in issue for issue in self.errors('let value = 1')))

    def test_geometry_notes_need_existing_nonpreview_code_and_reason(self):
        self.policy['geometry_notes'] = {'Sources/View.swift': {'reason': 'Native sheet width', 'anchors': ['.frame(width: 400)']}}
        self.assertEqual(self.errors('content.frame(width: 400)'), [])
        self.assertTrue(any('production code anchors' in issue for issue in self.errors('#Preview { content.frame(width: 400) }')))
        self.policy['geometry_notes']['Sources/View.swift']['reason'] = ''
        self.assertTrue(any('Invalid geometry' in issue for issue in self.errors('content.frame(width: 400)')))

    def test_policy_roots_cannot_escape_the_checkout(self):
        self.policy['roots'] = ['../']
        errors, _ = source_errors(self.root, self.policy)
        self.assertTrue(any('Invalid design policy root' in issue for issue in errors))

    def test_malformed_scope_metadata_is_reported_without_crashing(self):
        for occurrences in [None, 'line', [{'code': [], 'count': 1}], [{'code': 'content.padding(2)', 'count': True}]]:
            self.policy['exceptions'] = {'raw_inset': {'Sources/View.swift': {'reason': 'Specific clearance', 'occurrences': occurrences}}}
            self.assertTrue(self.errors('content.padding(2)'))

    def test_current_reviewed_policy_has_no_stale_or_blanket_scopes(self):
        errors, count = source_errors()
        self.assertGreater(count, 0)
        self.assertEqual(errors, [])


if __name__ == '__main__':
    unittest.main()
