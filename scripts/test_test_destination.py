"""The model-test entry point must never select a physical device."""
from pathlib import Path
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ModelDestinationTests(unittest.TestCase):
    def accepts(self, value):
        result = subprocess.run(
            ['bash', '-c', 'source "$1"; validate_model_test_destination "$2"',
             'destination-check', str(ROOT / 'scripts/test_destination.sh'), value],
            capture_output=True, text=True)
        return result.returncode == 0

    def test_explicit_simulators(self):
        for value in ('platform=iOS Simulator,id=fixture',
                      'platform=visionOS Simulator,name=Apple Vision Pro,OS=27.3',
                      'name=iPhone 18 Pro,platform=iOS Simulator'):
            with self.subTest(value=value):
                self.assertTrue(self.accepts(value))

    def test_physical_missing_ambiguous_and_malformed_destinations(self):
        for value in ('platform=iOS,name=Simulator', 'platform=visionOS,id=fixture',
                      'platform=iOS Simulator', 'platform=iOS Simulator,id=',
                      'platform=iOS Simulator,id=one,name=two',
                      'platform=iOS Simulator,id=one,platform=iOS',
                      'platform=iOS Simulator,,id=one', 'platform=iOS Simulator,id=one,',
                      'platform=iOS Simulator,id=one,unknown=value'):
            with self.subTest(value=value):
                self.assertFalse(self.accepts(value))


if __name__ == '__main__':
    unittest.main()
