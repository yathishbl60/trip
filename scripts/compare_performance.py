"""Compare matching workloads; timing regression failures are explicitly opt-in."""
import argparse
import json
import math
import pathlib


def read_report(path):
    report = json.loads(pathlib.Path(path).read_text())
    if report["schemaVersion"] != 1:
        raise ValueError("Unsupported report schema")
    metrics = {metric["name"]: metric for metric in report["metrics"]}
    if not metrics or len(metrics) != len(report["metrics"]):
        raise ValueError("Metrics must be nonempty and uniquely named")
    for metric in metrics.values():
        if metric["sampleCount"] <= 0 or metric["warmupCount"] < 0:
            raise ValueError(f"Invalid sample counts for {metric['name']}")
        for field in ("medianMicroseconds", "p95Microseconds"):
            if not math.isfinite(metric[field]) or metric[field] <= 0:
                raise ValueError(f"Invalid timing for {metric['name']}")
    return report, metrics


def validate(before, after, old, new, allow_environment):
    for field in ("schemaVersion", "workloadVersion"):
        if before[field] != after[field]:
            raise ValueError(f"Cannot compare different {field} values")
    if before["environment"] != after["environment"]:
        if not allow_environment:
            raise ValueError("Environments differ; rerun on the same machine/toolchain or use --allow-environment-mismatch")
        print("WARNING: environment changed; timing differences may not come from code.")
    if old.keys() != new.keys():
        raise ValueError("Metric sets differ; establish a new baseline")
    for name in old:
        for field in ("sampleCount", "warmupCount", "checksum"):
            if old[name][field] != new[name][field]:
                raise ValueError(f"Work changed: {name} {field}; establish a new baseline")


def compare(old, new, limit):
    failed = False
    print("Metric | median change | p95 change (positive means slower)")
    for name in sorted(old):
        changes = [(new[name][key] / old[name][key] - 1) * 100
                   for key in ("medianMicroseconds", "p95Microseconds")]
        print(f"{name} | {changes[0]:+.1f}% | {changes[1]:+.1f}%")
        failed |= limit is not None and max(changes) > limit
    return failed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline")
    parser.add_argument("current")
    parser.add_argument("--max-regression", type=float, help="Fail when median or p95 slows by more than this percent")
    parser.add_argument("--allow-environment-mismatch", action="store_true")
    args = parser.parse_args()
    if args.max_regression is not None and (not math.isfinite(args.max_regression) or args.max_regression < 0):
        parser.error("--max-regression must be a finite nonnegative percent")
    before, old = read_report(args.baseline)
    after, new = read_report(args.current)
    validate(before, after, old, new, args.allow_environment_mismatch)
    print(f"Comparing {before['revision'][:8]} -> {after['revision'][:8]}; dirty: {before['dirty']} -> {after['dirty']}")
    if not before["checksPassed"] or not after["checksPassed"]:
        print("NOTE: at least one report was recorded without correctness checks.")
    raise SystemExit(1 if compare(old, new, args.max_regression) else 0)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, KeyError, TypeError, OSError) as error:
        raise SystemExit(str(error))
