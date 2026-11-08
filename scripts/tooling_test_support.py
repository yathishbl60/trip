"""Isolated repository fixtures for contributor-tool regression tests."""
import json
from pathlib import Path
import tempfile
import unittest


class WorkspaceFixture(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.owners = {
            'App': {'path': 'trip/App', 'dependencies': ['Trips'], 'packages': [],
                    'guide': 'docs/App.md', 'entryPoints': ['trip/App/Host.swift'], 'purpose': 'Composition'},
            'Trips': {'path': 'trip/Features/Trips', 'dependencies': [], 'packages': ['TripDomain'],
                      'guide': 'docs/Trips.md', 'entryPoints': [], 'purpose': 'Planning'},
            'DesignSystem': {'path': 'trip/DesignSystem', 'dependencies': [], 'packages': [],
                             'guide': 'docs/Design.md', 'entryPoints': [], 'purpose': 'Styles'},
        }
        self.write('scripts/architecture/app-ownership.json', json.dumps(self.owners))
        self.write('Packages/TripKit/modules.json', json.dumps({'TripDomain': ['TripLocalization'], 'TripLocalization': []}))
        for path in ['AGENTS.md', 'ARCHITECTURE.md', 'CONTRIBUTING.md', 'docs/Skills.md',
                     'docs/App.md', 'docs/Trips.md', 'docs/Design.md', 'docs/PreviewSupport.md',
                     'Packages/TripKit/README.md', 'Packages/TripKit/Package.swift']:
            self.write(path, 'Fixture\n')
        for path in ['trip/App/Host.swift', 'trip/Features/Trips/TripModel.swift', 'trip/DesignSystem/Theme.swift',
                     'trip/PreviewSupport/PreviewTripServices.swift', 'Packages/TripKit/Sources/TripDomain/Value.swift',
                     'Packages/TripKit/Sources/TripLocalization/Text.swift']:
            self.write(path, 'struct Fixture {}\n')
        route = {'when': 'Changing a contract', 'project': [], 'global': ['app-development']}
        self.routes = {'defaults': {kind: [route] for kind in ['source', 'package', 'preview']}, 'owners': {}}
        self.save_routes()

    def write(self, name, text):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        return path

    def save_routes(self):
        self.write('scripts/factory/skill-routes.json', json.dumps(self.routes))
