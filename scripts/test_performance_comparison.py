"""Exercise the comparison CLI's pass/fail behavior with isolated synthetic reports."""
import copy
import json
import pathlib
import subprocess
import sys
import tempfile
import unittest

COMPARATOR = pathlib.Path(__file__).with_name("compare_performance.py")


class ComparisonChecks(unittest.TestCase):
    def setUp(self):
        self.report = {
            "schemaVersion": 1, "workloadVersion": 1, "checksPassed": True,
            "revision": "12345678", "dirty": False, "environment": {"cpu": "fixture"},
            "metrics": [{"name": "layout", "sampleCount": 200, "warmupCount": 20,
                         "checksum": 100, "medianMicroseconds": 10, "p95Microseconds": 12}],
        }

    def invoke(self, current, *arguments):
        with tempfile.TemporaryDirectory() as directory:
            baseline = pathlib.Path(directory) / "before.json"
            after = pathlib.Path(directory) / "after.json"
            baseline.write_text(json.dumps(self.report))
            after.write_text(json.dumps(current))
            return subprocess.run([sys.executable, str(COMPARATOR), str(baseline), str(after), *arguments],
                                  capture_output=True, text=True)

    def test_identical_reports_pass(self):
        result = self.invoke(self.report, "--max-regression", "0")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_regression_gate_is_optional(self):
        current = copy.deepcopy(self.report)
        current["metrics"][0]["medianMicroseconds"] = 20
        self.assertEqual(self.invoke(current).returncode, 0)
        self.assertEqual(self.invoke(current, "--max-regression", "20").returncode, 1)

    def test_p95_regression_also_fails(self):
        current = copy.deepcopy(self.report)
        current["metrics"][0]["p95Microseconds"] = 24
        self.assertEqual(self.invoke(current, "--max-regression", "20").returncode, 1)

    def test_incompatible_or_invalid_metrics_fail(self):
        for key, value in [("name", "other"), ("checksum", 99), ("sampleCount", 0),
                           ("warmupCount", 21), ("medianMicroseconds", float("nan")), ("p95Microseconds", 0)]:
            with self.subTest(field=key):
                current = copy.deepcopy(self.report)
                current["metrics"][0][key] = value
                self.assertNotEqual(self.invoke(current).returncode, 0)

    def test_versions_must_match(self):
        for key in ("schemaVersion", "workloadVersion"):
            current = copy.deepcopy(self.report)
            current[key] = 2
            self.assertNotEqual(self.invoke(current).returncode, 0)

    def test_environment_override_is_explicit(self):
        current = copy.deepcopy(self.report)
        current["environment"]["cpu"] = "different"
        self.assertNotEqual(self.invoke(current).returncode, 0)
        result = self.invoke(current, "--allow-environment-mismatch")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("WARNING", result.stdout)

    def test_invalid_threshold_rejected(self):
        for value in ("-1", "nan", "inf"):
            self.assertEqual(self.invoke(self.report, "--max-regression", value).returncode, 2)


if __name__ == "__main__":
    unittest.main(verbosity=2)
