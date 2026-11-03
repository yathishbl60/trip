"""Attach reproducibility metadata to a completed Swift benchmark report."""
import datetime
import hashlib
import json
import pathlib
import platform
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
FLAGS = "-D TRIP_STANDALONE -O -whole-module-optimization -swift-version 6 -strict-concurrency=complete -default-isolation MainActor -enable-upcoming-feature MemberImportVisibility"


def command(*arguments):
    return subprocess.check_output(arguments, cwd=ROOT, text=True, stderr=subprocess.STDOUT).strip()


def source_digest():
    paths = [ROOT / name for name in (ROOT / "Performance/sources.txt").read_text().splitlines()]
    paths += sorted((ROOT / "Performance").glob("*.swift"))
    digest = hashlib.sha256()
    for path in paths:
        digest.update(str(path.relative_to(ROOT)).encode())
        digest.update(path.read_bytes())
    return digest.hexdigest()


def environment():
    return {
        "architecture": platform.machine(),
        "macOS": platform.mac_ver()[0],
        "cpu": command("sysctl", "-n", "machdep.cpu.brand_string"),
        "compiler": command("xcrun", "--sdk", "macosx", "swiftc", "--version"),
        "sdk": command("xcrun", "--sdk", "macosx", "--show-sdk-version"),
        "flags": FLAGS,
    }


def main():
    if len(sys.argv) != 3:
        raise SystemExit("Usage: performance_report.py raw.json report.json")
    report = json.loads(pathlib.Path(sys.argv[1]).read_text())
    report.update(environment=environment(), sourceDigest=source_digest(),
                  revision=command("git", "rev-parse", "HEAD"),
                  dirty=bool(command("git", "status", "--porcelain")),
                  recordedAt=datetime.datetime.now(datetime.timezone.utc).isoformat())
    output = pathlib.Path(sys.argv[2]).expanduser().resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print(f"Saved {len(report['metrics'])} metrics to {output}")


if __name__ == "__main__":
    main()
