"""Regression checks for ownership enforcement; no Swift compilation or services."""
import json
from pathlib import Path
import tempfile
import unittest
from architecture.feature_boundaries import check_features, check_package_app_references


class ArchitectureChecks(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.owners = {
            "App": {"path": "trip/App", "dependencies": ["Explore", "Trips"], "packages": []},
            "Explore": {"path": "trip/Features/Explore", "dependencies": [], "packages": ["TripDomain"]},
            "Trips": {"path": "trip/Features/Trips", "dependencies": [], "packages": ["TripDomain"]},
        }
        self.write("trip/App/AppModel.swift", "class AppModel { var explore: ExploreModel }")
        self.write("trip/Features/Explore/ExploreModel.swift", "class ExploreModel {}")
        self.write("trip/Features/Trips/TripModel.swift", "class TripModel {}")
        self.write("trip/PreviewSupport/Fixtures.swift", "enum LocalFixtures {}")

    def write(self, name, text):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)

    def check(self):
        self.write("scripts/architecture/app-ownership.json", json.dumps(self.owners))
        return check_features(self.root, {"TripDomain", "TripStorage"})

    def test_host_can_compose_features(self):
        self.assertEqual(self.check(), [])

    def test_feature_cannot_reach_into_sibling_or_host(self):
        self.write("trip/Features/Trips/Binding.swift", "typealias Host = AppModel\nstruct Binding { var map: ExploreModel }")
        self.assertTrue(any("AppModel, ExploreModel" in error for error in self.check()))

    def test_only_declared_package_dependencies_are_allowed(self):
        self.write("trip/Features/Explore/Storage.swift", "import TripStorage")
        self.assertTrue(any("TripStorage" in error for error in self.check()))

    def test_previews_are_debug_only(self):
        self.write("trip/Features/Trips/Preview.swift", "#if DEBUG\nlet fixture = LocalFixtures.self\n#endif")
        self.assertEqual(self.check(), [])
        self.write("trip/Features/Trips/Preview.swift", "let fixture = LocalFixtures.self")
        self.assertTrue(any("LocalFixtures" in error for error in self.check()))

    def test_comments_and_strings_do_not_create_dependencies(self):
        self.write("trip/Features/Trips/Notes.swift", '// ExploreModel\nlet title = "AppModel"\n/* ExploreModel */')
        self.assertEqual(self.check(), [])

    def test_unknown_source_folder_is_rejected(self):
        self.write("trip/Misc/Mystery.swift", "struct Mystery {}")
        self.assertTrue(any("no owner" in error for error in self.check()))

    def test_cycles_are_rejected(self):
        self.owners["Trips"]["dependencies"] = ["App"]
        self.assertTrue(any("Cyclic" in error for error in self.check()))

    def test_new_app_types_are_automatically_protected(self):
        self.write("trip/Features/Trips/NewModel.swift", "class NewModel {}")
        self.write("Packages/TripKit/Sources/TripDomain/Leak.swift", "struct Leak { var value: NewModel }")
        errors = check_package_app_references(self.root, self.root / "Packages/TripKit")
        self.assertTrue(any("NewModel" in error for error in errors))

    def test_uikit_bridges_are_rejected(self):
        self.write("trip/Features/Trips/Bridge.swift", "struct Bridge: UIViewRepresentable {}")
        self.assertTrue(any("UIKit" in error for error in self.check()))


if __name__ == "__main__":
    unittest.main()
