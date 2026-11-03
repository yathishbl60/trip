"""Validate Trip-owned skills without depending on personal/global installations."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / '.agents/skills'


def check_skills():
    errors = []
    folders = [path for path in SKILLS.iterdir() if path.is_dir()]
    for folder in folders:
        entry = folder / 'SKILL.md'
        if folder.is_symlink() or not folder.name.startswith('trip-'):
            errors.append(f'Only Trip-owned skills belong here: {folder.relative_to(ROOT)}')
        if entry.is_symlink():
            errors.append(f'Project entrypoint must not be a symlink: {entry.relative_to(ROOT)}')
        if not entry.is_file():
            errors.append(f'Missing entrypoint: {entry.relative_to(ROOT)}')
            continue
        header = entry.read_text().split('---', 2)
        metadata = header[1] if len(header) == 3 and header[0] == '' else ''
        name = re.search(r'(?m)^name:[ \t]*([^\n]+)', metadata)
        if not name or name.group(1).strip('"\' ') != folder.name:
            errors.append(f'Name must match project skill directory: {entry.relative_to(ROOT)}')
        if not re.search(r'(?m)^description:[ \t]*\S', metadata):
            errors.append(f'Missing trigger description: {entry.relative_to(ROOT)}')
    for path in SKILLS.rglob('*.md'):
        source = path.read_text()
        if len(source.splitlines()) > 50:
            errors.append(f'{path.relative_to(ROOT)} exceeds 50 lines')
        for link in re.findall(r'\]\(([^)]+)\)', source):
            if '://' not in link and not link.startswith('#'):
                if not (path.parent / link.split('#')[0]).exists():
                    errors.append(f'Broken reference in {path.relative_to(ROOT)}: {link}')
    return errors, len(folders)


if __name__ == '__main__':
    issues, count = check_skills()
    for issue in issues:
        print(issue)
    print(f'Checked {count} Trip-only skills, names, references, and Markdown limits; no global dependency.')
    raise SystemExit(bool(issues))
