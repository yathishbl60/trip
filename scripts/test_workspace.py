"""Contributor tooling regression cases; no Swift compilation or live services."""
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from contextlib import redirect_stderr, redirect_stdout
from io import StringIO
from factory.catalog import catalog, check_catalog, context, locate
from factory.impact import impact
from factory.metrics import metrics
from factory.scaffold import create_files, plan, rollback, scaffold
from factory.skills import check_routes, selection
from tooling_test_support import WorkspaceFixture
import workspace


class CatalogChecks(WorkspaceFixture):
    def test_context_uses_declared_contracts_and_consumers(self):
        result = context(self.root, 'TripDomain')
        self.assertIn('Trips', result['dependents'])
        self.assertEqual(result['dependencyGuides'], {'TripLocalization': 'Packages/TripKit/README.md'})
        self.assertEqual(result['skills']['workflow']['name'], 'app-development')
        self.assertEqual(check_catalog(self.root), [])

    def test_locate_resolves_planned_files_and_rejects_outside_or_unknown(self):
        self.assertEqual(locate(self.root, 'trip/Features/Trips/New.swift')['owner'], 'Trips')
        for path in ['../outside.swift', 'docs/Trips.md']:
            with self.assertRaises(ValueError):
                locate(self.root, path)

    def test_overlapping_owners_and_missing_references_are_reported(self):
        self.owners['Duplicate'] = dict(self.owners['Trips'])
        self.write('scripts/architecture/app-ownership.json', json.dumps(self.owners))
        with self.assertRaises(ValueError):
            locate(self.root, 'trip/Features/Trips')
        (self.root / 'docs/Trips.md').unlink()
        self.assertTrue(any('missing workspace reference' in issue for issue in check_catalog(self.root)))

    def test_routes_reject_competing_global_names_and_missing_local_skill(self):
        self.routes['owners']['Trips'] = [{'when': 'Editing', 'project': ['trip-missing'], 'global': ['swiftui-review']}]
        self.save_routes()
        issues = check_routes(self.root, catalog(self.root))
        self.assertTrue(any('missing project skill' in issue for issue in issues))
        self.assertTrue(any('unified global' in issue for issue in issues))

    def test_routes_validate_schema_before_selection(self):
        self.routes['defaults']['source'][0]['global'] = ['app-development', 'app-development']
        self.save_routes()
        with self.assertRaisesRegex(ValueError, 'duplicate'):
            selection(self.root, 'Trips', 'source')

    def test_project_skill_cannot_resolve_through_external_symlink(self):
        with tempfile.TemporaryDirectory() as outside:
            external = Path(outside) / 'SKILL.md'
            external.write_text('external')
            link = self.root / '.agents/skills/trip-external'
            link.parent.mkdir(parents=True)
            link.symlink_to(external.parent, target_is_directory=True)
            self.routes['owners']['Trips'] = [{'when': 'Editing', 'project': ['trip-external'], 'global': []}]
            self.save_routes()
            self.assertTrue(any('repository' in issue for issue in check_routes(self.root, catalog(self.root))))


class ImpactChecks(WorkspaceFixture):
    def test_reverse_dependencies_are_transitive_but_do_not_select_siblings(self):
        result = impact(self.root, ['Packages/TripKit/Sources/TripDomain/Deleted.swift'])
        self.assertEqual(result['directOwners'], ['TripDomain'])
        self.assertEqual(set(result['affectedOwners']), {'TripDomain', 'Trips', 'App', 'PreviewSupport'})
        self.assertNotIn('DesignSystem', result['affectedOwners'])

    def test_directory_and_guide_paths_have_owners(self):
        self.assertEqual(impact(self.root, ['docs/Trips.md'])['directOwners'], ['Trips'])
        self.assertEqual(impact(self.root, ['trip/Features'])['directOwners'], ['Trips'])

    def test_unowned_and_escaped_paths_are_explicit(self):
        self.assertEqual(impact(self.root, ['scripts/new.py'])['unownedPaths'], ['scripts/new.py'])
        with self.assertRaises(ValueError):
            impact(self.root, ['../not-in-repo'])

    def test_range_and_default_changes_use_git_without_running_checks(self):
        with patch('factory.impact.changed_paths', return_value=['trip/Features/Trips/New.swift']) as changes:
            with patch('factory.impact.revision', return_value='abcdef'):
                result = impact(self.root, base='main', head='feature')
            changes.assert_called_once_with(self.root, 'main', 'feature')
            self.assertEqual(result['basis']['mode'], 'merge-base-to-head')
            self.assertEqual(result['directOwners'], ['Trips'])

    def test_manifest_changes_require_all_consumers(self):
        result = impact(self.root, ['Packages/TripKit/modules.json'])
        self.assertEqual(set(result['affectedOwners']), set(catalog(self.root)))

    def test_domain_edit_recommends_declared_domain_tests_and_hosted_models(self):
        self.write('Packages/TripKit/Package.swift', '.testTarget(name: "TripDomainTests", dependencies: ["TripDomain"])')
        result = impact(self.root, ['Packages/TripKit/Sources/TripDomain/Checklist.swift'])
        package = next(item for item in result['verification'] if item['command'] == 'bash scripts/test.sh package')
        self.assertEqual(package['affectedTestTargets'], ['TripDomainTests'])
        model = next(item for item in result['verification'] if item.get('affectedTestTargets') == ['TripAppTests'])
        self.assertIn('id=<simulator-UDID>', model['command'])
        self.assertTrue(model['requiresExplicitDestination'])

    def test_place_adapter_edit_recommends_its_public_contract_suite(self):
        self.write('Packages/TripKit/modules.json', json.dumps({'TripDomain': [], 'TripPlaces': ['TripDomain']}))
        self.write('Packages/TripKit/Package.swift', '.testTarget(name: "TripPlacesTests", dependencies: ["TripPlaces", "TripDomain"])')
        result = impact(self.root, ['Packages/TripKit/Sources/TripPlaces/PlaceFactory.swift'])
        package = next(item for item in result['verification'] if item['command'] == 'bash scripts/test.sh package')
        self.assertEqual(package['affectedTestTargets'], ['TripPlacesTests'])

    def test_hosted_test_sources_and_plan_map_to_app_and_request_model_execution(self):
        for path in ['TripAppTests/TripLibraryLifetimeTests.swift', 'TestPlans/TripModels.xctestplan',
                     'trip/Features/Trips/Models/Checklist/TripChecklistModel.swift']:
            result = impact(self.root, [path])
            self.assertEqual(result['unownedPaths'], [])
            self.assertIn('App', result['affectedOwners'])
            self.assertTrue(any(item.get('affectedTestTargets') == ['TripAppTests'] for item in result['verification']))


class ScaffoldChecks(WorkspaceFixture):
    def test_dry_run_does_not_create_files_and_write_registers_feature(self):
        original = (self.root / 'scripts/architecture/app-ownership.json').read_bytes()
        self.assertIn('Would create', scaffold(self.root, 'Journal', 'Record notes'))
        self.assertFalse((self.root / 'trip/Features/Journal').exists())
        self.assertEqual((self.root / 'scripts/architecture/app-ownership.json').read_bytes(), original)
        scaffold(self.root, 'Journal', 'Record notes', write=True)
        self.assertEqual(locate(self.root, 'trip/Features/Journal/Models/JournalModel.swift')['owner'], 'Journal')
        self.assertEqual(check_catalog(self.root), [])

    def test_type_collisions_and_existing_paths_are_rejected(self):
        self.write('trip/App/Existing.swift', 'extension JournalModel {}')
        with self.assertRaisesRegex(ValueError, 'already referenced'):
            plan(self.root, 'Journal', 'Record notes')
        with self.assertRaises(ValueError):
            plan(self.root, '../Escape', 'Record notes')

    def test_stale_manifest_before_creation_leaves_concurrent_content(self):
        files, manifest, original, updated = plan(self.root, 'Journal', 'Record notes')
        self.write(manifest, original.decode() + '\n')
        with self.assertRaisesRegex(ValueError, 'Ownership changed'):
            create_files(self.root, files, manifest, original, updated)
        self.assertFalse((self.root / 'trip/Features/Journal').exists())
        self.assertEqual((self.root / manifest).read_text(), original.decode() + '\n')

    def test_stale_manifest_during_creation_rolls_back_only_owned_files(self):
        files, manifest, original, updated = plan(self.root, 'Journal', 'Record notes')
        temporary_file = tempfile.NamedTemporaryFile

        def concurrent_change(*args, **kwargs):
            self.write(manifest, original.decode() + '\n')
            self.write(next(iter(files)), 'Concurrent edit\n')
            return temporary_file(*args, **kwargs)

        with patch('factory.scaffold.tempfile.NamedTemporaryFile', side_effect=concurrent_change):
            with self.assertRaisesRegex(ValueError, 'Retained changed'):
                create_files(self.root, files, manifest, original, updated)
        self.assertEqual((self.root / next(iter(files))).read_text(), 'Concurrent edit\n')
        self.assertFalse((self.root / 'docs/features/Journal.md').exists())

    def test_failed_manifest_replace_restores_clean_generated_files(self):
        files, manifest, original, updated = plan(self.root, 'Journal', 'Record notes')
        with patch('factory.scaffold.os.replace', side_effect=OSError('fixture failure')):
            with self.assertRaises(OSError):
                create_files(self.root, files, manifest, original, updated)
        self.assertEqual((self.root / manifest).read_bytes(), original)
        self.assertTrue(all(not (self.root / name).exists() for name in files))

    def test_rollback_keeps_incomplete_or_replaced_files(self):
        path = self.write('partial.swift', 'partial')
        identity = path.stat()
        record = {'path': path, 'identity': (identity.st_dev, identity.st_ino), 'complete': False, 'content': b'partial'}
        self.assertEqual(rollback([record], []), [path])
        record['complete'] = True
        replacement = self.write('replacement.swift', 'partial')
        os.replace(replacement, path)
        self.assertEqual(rollback([record], []), [path])


class MetricsChecks(WorkspaceFixture):
    def test_extensions_group_by_type_without_changing_policy(self):
        self.write('trip/Features/Trips/TripModel.swift', 'class TripModel { var saved = 0 }\n')
        self.write('trip/Features/Trips/TripModel+Edit.swift', 'extension TripModel { func edit() {} }\n')
        result = metrics(self.root, 'Trips')
        item = result['logicalTypes'][0]
        self.assertTrue(result['advisory'])
        self.assertEqual((item['type'], item['fileCount'], item['extensions']), ('TripModel', 2, 1))
        self.assertEqual(result['owners'][0]['filesOver100Lines'], 0)

    def test_imports_and_class_methods_do_not_invent_logical_types(self):
        self.write('trip/Features/Trips/TripModel.swift',
                   'import class Foundation.NSObject\nclass TripModel { class func make() {} }\n')
        result = metrics(self.root, 'Trips')
        self.assertEqual([item['type'] for item in result['logicalTypes']], ['TripModel'])


class CommandLineChecks(WorkspaceFixture):
    def test_impact_cli_produces_json_without_changing_existing_commands(self):
        output = StringIO()
        with patch.object(workspace, 'ROOT', self.root), patch('sys.argv', ['workspace.py', 'impact', 'docs/Trips.md', '--json']):
            with redirect_stdout(output):
                workspace.main()
        self.assertEqual(json.loads(output.getvalue())['directOwners'], ['Trips'])

    def test_context_cli_remains_compatible(self):
        output = StringIO()
        with patch.object(workspace, 'ROOT', self.root), patch('sys.argv', ['workspace.py', 'context', 'Trips', '--json']):
            with redirect_stdout(output):
                workspace.main()
        self.assertEqual(json.loads(output.getvalue())['name'], 'Trips')

    def test_doctor_optional_gate_reports_missing_prerequisites_and_fails(self):
        report = {'readyForSourceChecks': False, 'readyForCompilation': False}
        for flag, expected_failure in [([], False), (['--require-ready'], True)]:
            output = StringIO()
            with patch.object(workspace, 'doctor', return_value=report), patch('sys.argv', ['workspace.py', 'doctor', '--json', *flag]):
                with redirect_stdout(output), redirect_stderr(StringIO()):
                    if expected_failure:
                        with self.assertRaises(SystemExit) as failure:
                            workspace.main()
                        self.assertEqual(failure.exception.code, 1)
                    else:
                        workspace.main()
            self.assertEqual(json.loads(output.getvalue()), report)

    def test_doctor_gate_accepts_complete_prerequisites_without_running_checks(self):
        report = {'readyForSourceChecks': True, 'readyForCompilation': True}
        with patch.object(workspace, 'doctor', return_value=report), patch('sys.argv', ['workspace.py', 'doctor', '--require-ready', '--json']):
            with redirect_stdout(StringIO()):
                workspace.main()


if __name__ == '__main__':
    unittest.main()
