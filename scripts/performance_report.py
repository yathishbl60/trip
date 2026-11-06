"""Attach reproducibility metadata to a completed Swift benchmark report."""
import datetime
import hashlib
import json
import pathlib
import platform
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
FLAGS = "-D TRIP_STANDALONE -O -whole-module-optimization -parse-as-library -swift-version 6 -strict-concurrency=complete -default-isolation MainActor -enable-upcoming-feature MemberImportVisibility"


def command(*arguments, cwd=ROOT):
    return subprocess.check_output(arguments, cwd=cwd, text=True, stderr=subprocess.STDOUT).strip()


def source_paths(root):
    names = (root / "Performance/sources.txt").read_text().splitlines()
    paths = [root / name for name in names if name and not name.startswith("#")]
    return paths + sorted((root / "Performance").glob("*.swift"))


def source_digest(root=ROOT):
    digest = hashlib.sha256()
    for path in source_paths(root):
        digest.update(str(path.relative_to(root)).encode())
        digest.update(path.read_bytes())
    return digest.hexdigest()


def checkout_state(root=ROOT):
    top = pathlib.Path(command("git", "rev-parse", "--show-toplevel", cwd=root)).resolve()
    if top != root.resolve():
        raise ValueError(f"Cannot use the enclosing checkout's revision and status for snapshot {root}")
    return command("git", "rev-parse", "HEAD", cwd=root), bool(command("git", "status", "--porcelain", cwd=root))


def environment():
    return {
        "architecture": platform.machine(),
        "macOS": platform.mac_ver()[0],
        "cpu": command("sysctl", "-n", "machdep.cpu.brand_string"),
        "compiler": command("xcrun", "--sdk", "macosx", "swiftc", "--version"),
        "sdk": command("xcrun", "--sdk", "macosx", "--show-sdk-version"),
        "flags": FLAGS,
    }


def write_report(raw_path, output_path, *, digest, revision, dirty):
    report = json.loads(raw_path.read_text())
    report.update(environment=environment(), sourceDigest=digest, revision=revision, dirty=dirty,
                  recordedAt=datetime.datetime.now(datetime.timezone.utc).isoformat())
    output = output_path.expanduser().resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    print(f"Saved {len(report['metrics'])} metrics to {output}")


def main():
    if len(sys.argv) != 3:
        raise SystemExit("Usage: performance_report.py raw.json report.json")
    try:
        revision, dirty = checkout_state()
    except ValueError as error:
        raise SystemExit(str(error))
    write_report(pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]), digest=source_digest(),
                 revision=revision, dirty=dirty)


if __name__ == "__main__":
    main()
