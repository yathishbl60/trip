"""Check local worktree/index whitespace and optionally a committed base/head range."""
import argparse
from pathlib import Path
import subprocess
from factory.git_state import git, revision


def commands(root, base=None, head='HEAD'):
    result = [['git', '-C', str(root), 'diff', '--check', '--'],
              ['git', '-C', str(root), 'diff', '--cached', '--check', '--']]
    if base:
        common = git(root, 'merge-base', revision(root, base), revision(root, head)).strip()
        result.append(['git', '-C', str(root), 'diff', '--check', common, revision(root, head), '--'])
    return result


def check(root, base=None, head='HEAD'):
    failed = False
    for command in commands(root, base, head):
        failed = subprocess.run(command).returncode != 0 or failed
    return int(failed)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base', help='Compare merge-base(base, head) through head as well as local edits')
    parser.add_argument('--head', default='HEAD')
    args = parser.parse_args()
    if args.head != 'HEAD' and not args.base:
        parser.error('--head requires --base')
    try:
        return check(Path(__file__).resolve().parents[1], args.base, args.head)
    except ValueError as error:
        parser.error(str(error))


if __name__ == '__main__':
    raise SystemExit(main())
