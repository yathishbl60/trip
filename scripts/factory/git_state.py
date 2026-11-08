"""Read Git state without changing the checkout, index, refs, or configuration."""
import subprocess


def git(root, *arguments):
    result = subprocess.run(['git', '-C', str(root), *arguments], capture_output=True, text=True)
    if result.returncode:
        raise ValueError(result.stderr.strip() or f'git {arguments[0]} failed')
    return result.stdout


def revision(root, value):
    return git(root, 'rev-parse', '--verify', '--end-of-options', f'{value}^{{commit}}').strip()


def changed_paths(root, base=None, head='HEAD'):
    if base:
        start, end = revision(root, base), revision(root, head)
        common = git(root, 'merge-base', start, end).strip()
        values = git(root, 'diff', '--name-only', '--no-renames', '-z', common, end, '--')
    else:
        values = git(root, 'diff', '--name-only', '--no-renames', '-z', '--')
        values += git(root, 'diff', '--cached', '--name-only', '--no-renames', '-z', '--')
        values += git(root, 'ls-files', '--others', '--exclude-standard', '-z')
    return sorted(set(filter(None, values.split('\0'))))
