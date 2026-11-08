"""Exercise provenance and whitespace behavior in disposable Git workspaces."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
from check_whitespace import check, commands
from factory.doctor import doctor, environment_for_xcode, version
from factory.git_state import changed_paths
from tooling_test_support import WorkspaceFixture
from verify import run, snapshot


class GitFixture(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name).resolve()
        subprocess.run(['git', 'init', '-q', str(self.root)], check=True)
        (self.root / '.gitignore').write_text('.build/\n')
        subprocess.run(['git', '-C', str(self.root), 'add', '.gitignore'], check=True)


class WhitespaceChecks(GitFixture):
    def test_staged_only_whitespace_is_rejected(self):
        path = self.root / 'source.txt'
        path.write_text('value   \n')
        subprocess.run(['git', '-C', str(self.root), 'add', 'source.txt'], check=True)
        self.assertEqual(check(self.root), 1)
        path.write_text('value\n')
        subprocess.run(['git', '-C', str(self.root), 'add', 'source.txt'], check=True)
        self.assertEqual(check(self.root), 0)

    def test_worktree_whitespace_and_untracked_impact_are_observed(self):
        path = self.root / 'source.txt'
        path.write_text('value\n')
        subprocess.run(['git', '-C', str(self.root), 'add', 'source.txt'], check=True)
        path.write_text('value   \n')
        (self.root / 'new.txt').write_text('untracked\n')
        self.assertEqual(check(self.root), 1)
        self.assertEqual(set(changed_paths(self.root)), {'.gitignore', 'source.txt', 'new.txt'})

    def test_ci_range_uses_resolved_merge_base_and_head(self):
        with patch('check_whitespace.revision', side_effect=lambda root, ref: {'base': 'a' * 40, 'head': 'b' * 40}[ref]):
            with patch('check_whitespace.git', return_value='c' * 40 + '\n') as invocation:
                result = commands(self.root, 'base', 'head')
        self.assertEqual(result[-1][-3:], ['c' * 40, 'b' * 40, '--'])
        invocation.assert_called_once_with(self.root, 'merge-base', 'a' * 40, 'b' * 40)


class ProvenanceChecks(GitFixture):
    def run_command(self, program, output='record.json'):
        path = self.root / '.build/verification' / output
        with patch('verify.toolchain', return_value={'fixture': True}):
            code = run(self.root, [sys.executable, '-c', program], 'tooling', path)
        return code, json.loads(path.read_text())

    def test_records_actual_failure_and_separate_evidence_categories(self):
        code, record = self.run_command('raise SystemExit(7)')
        self.assertEqual(code, 7)
        self.assertEqual(record['result'], 'failed')
        self.assertIn('visual-device', record['unverifiedCategories'])
        self.assertIn('compilation', record['unverifiedCategories'])
        self.assertFalse(record['sourceChangedDuringRun'])

    def test_content_digest_detects_edits_during_the_command(self):
        code, record = self.run_command("from pathlib import Path; Path('changed.txt').write_text('changed')")
        self.assertEqual(code, 0)
        self.assertTrue(record['sourceChangedDuringRun'])
        self.assertNotEqual(record['before']['sourceDigest'], record['after']['sourceDigest'])

    def test_generated_outputs_are_excluded_from_source_digest(self):
        before = snapshot(self.root)
        (self.root / '.build').mkdir()
        (self.root / '.build/log.txt').write_text('generated')
        self.assertEqual(before['sourceDigest'], snapshot(self.root)['sourceDigest'])

    def test_record_cannot_overwrite_or_escape_output_root(self):
        output = self.root / '.build/verification/record.json'
        output.parent.mkdir(parents=True)
        output.write_text('existing')
        for path in [output, self.root / 'source.json']:
            with self.assertRaises(ValueError):
                run(self.root, [sys.executable, '-c', 'pass'], 'tooling', path)
        self.assertEqual(output.read_text(), 'existing')

    def test_symlink_output_escape_is_rejected_before_command_execution(self):
        with tempfile.TemporaryDirectory() as outside:
            (self.root / '.build').symlink_to(outside, target_is_directory=True)
            with patch('verify.execute') as command:
                with self.assertRaises(ValueError):
                    run(self.root, ['unused'], 'tooling', self.root / '.build/record.json')
            command.assert_not_called()

    def test_output_is_reserved_before_the_verification_command(self):
        output = self.root / '.build/verification/record.json'

        def inspect_reservation(*arguments):
            self.assertEqual(json.loads(output.read_text())['result'], 'running')
            return 0, None

        with patch('verify.toolchain', return_value={'fixture': True}), patch('verify.execute', side_effect=inspect_reservation):
            self.assertEqual(run(self.root, ['fixture'], 'tooling', output), 0)
        self.assertEqual(json.loads(output.read_text())['result'], 'passed')


class DoctorChecks(WorkspaceFixture):
    def test_explicit_xcode_selection_is_preserved_without_probing(self):
        with patch('factory.doctor.probe') as query:
            result = environment_for_xcode({'DEVELOPER_DIR': '/fixture/Xcode/Developer'})
        query.assert_not_called()
        self.assertEqual(result['DEVELOPER_DIR'], '/fixture/Xcode/Developer')

    def test_unsupported_host_reports_missing_prerequisites_without_building(self):
        with patch('factory.doctor.platform.system', return_value='Linux'):
            with patch('factory.doctor.probe') as query:
                result = doctor(self.root)
        query.assert_not_called()
        self.assertFalse(result['readyForSourceChecks'])
        self.assertFalse(result['readyForCompilation'])
        self.assertTrue(result['readOnly'])

    def test_sdk_version_comparison_is_numeric(self):
        self.assertGreater(version('27.10'), version('27.3'))
        self.assertLess(version('27.2'), version('27.3'))


if __name__ == '__main__':
    unittest.main()
