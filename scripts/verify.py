#!/usr/bin/env python3
"""Run one explicitly chosen command and retain its actual verification provenance."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sys
import time
import uuid
from factory.doctor import environment_for_xcode, probe
from factory.git_state import git, revision

KINDS = ('source', 'tooling', 'compilation', 'executable', 'performance')


def snapshot(root):
    try:
        commit = revision(root, 'HEAD')
    except ValueError:
        commit = None
    status = git(root, 'status', '--porcelain=v1', '--untracked-files=all')
    names = git(root, 'ls-files', '-z') + git(root, 'ls-files', '--others', '--exclude-standard', '-z')
    digest = hashlib.sha256()
    for name in sorted(set(filter(None, names.split('\0')))):
        path = root / name
        digest.update(name.encode() + b'\0')
        if path.is_symlink():
            digest.update(b'link\0' + os.readlink(path).encode())
        elif path.is_file():
            digest.update(b'file\0' + path.read_bytes())
        else:
            digest.update(b'missing\0')
    return {'revision': commit, 'dirty': bool(status.strip()), 'status': status.splitlines(),
            'sourceDigest': digest.hexdigest()}


def toolchain(environment):
    result = {'system': platform.system(), 'release': platform.release(), 'architecture': platform.machine(),
              'python': platform.python_version(), 'developerDirectory': environment.get('DEVELOPER_DIR', 'system-selected')}
    if platform.system() == 'Darwin':
        result['xcode'] = probe(['xcodebuild', '-version'], environment)
        result['swift'] = probe(['xcrun', 'swift', '--version'], environment)
    return result


def run(root, command, kind, output, configuration=None, target_platform=None):
    if not command:
        raise ValueError('Supply a command after --; no verification runs by default.')
    root = root.resolve()
    output = (output if output.is_absolute() else root / output).resolve()
    if not output.is_relative_to(root / '.build'):
        raise ValueError('Verification records must be inside the repository .build directory.')
    environment = environment_for_xcode()
    before, environment_record = snapshot(root), toolchain(environment)
    started, timer = datetime.now(timezone.utc), time.monotonic()
    output.parent.mkdir(parents=True, exist_ok=True)
    try:
        destination = output.open('x')
    except FileExistsError as error:
        raise ValueError(f'Refusing to overwrite an existing verification record: {output}') from error
    with destination:
        initial = {'schemaVersion': 1, 'kind': kind, 'command': command, 'configuration': configuration,
                   'platform': target_platform, 'startedAt': started.isoformat(), 'result': 'running',
                   'before': before, 'toolchain': environment_record}
        json.dump(initial, destination, indent=2)
        destination.flush()
        exit_code, error = execute(root, command, environment)
        after = snapshot(root)
        record = initial | {
              'finishedAt': datetime.now(timezone.utc).isoformat(), 'durationSeconds': round(time.monotonic() - timer, 3),
              'exitCode': exit_code, 'result': 'passed' if exit_code == 0 else 'failed', 'error': error,
              'before': before, 'after': after, 'sourceChangedDuringRun': before['sourceDigest'] != after['sourceDigest'],
              'toolchain': environment_record,
              'unverifiedCategories': [value for value in (*KINDS, 'visual-device') if value != kind],
              'limitations': 'Exit status verifies only the invoked command at the recorded before/after snapshots. The declared category is supplied by the caller; it does not establish visual or device acceptance.'}
        destination.seek(0)
        destination.truncate()
        json.dump(record, destination, indent=2)
        destination.write('\n')
    print(f'Verification record: {output}', file=sys.stderr)
    return exit_code


def execute(root, command, environment):
    try:
        return subprocess.run(command, cwd=root, env=environment).returncode, None
    except KeyboardInterrupt:
        return 130, 'Interrupted'
    except OSError as problem:
        return 127, str(problem)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--kind', choices=KINDS, required=True)
    parser.add_argument('--configuration')
    parser.add_argument('--platform', dest='target_platform')
    parser.add_argument('--output', type=Path)
    parser.add_argument('command', nargs=argparse.REMAINDER)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    output = args.output or root / '.build/verification' / f'{datetime.now(timezone.utc):%Y%m%dT%H%M%SZ}-{uuid.uuid4().hex[:8]}.json'
    command = args.command[1:] if args.command[:1] == ['--'] else args.command
    try:
        code = run(root, command, args.kind, output, args.configuration, args.target_platform)
        return code if code >= 0 else 128 - code
    except (ValueError, OSError) as error:
        parser.error(str(error))


if __name__ == '__main__':
    raise SystemExit(main())
