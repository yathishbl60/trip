"""Conservative change impact derived from the repository's ownership graph."""
from pathlib import Path
import re
from .catalog import catalog
from .git_state import changed_paths, revision

GLOBAL_INPUTS = {'AGENTS.md', 'ARCHITECTURE.md', 'CONTRIBUTING.md',
                 'Packages/TripKit/Package.swift', 'Packages/TripKit/modules.json',
                 'scripts/architecture/app-ownership.json'}


def owners_for_path(root, value, areas):
    path = Path(value)
    absolute = (path if path.is_absolute() else root / path).resolve()
    if not absolute.is_relative_to(root.resolve()):
        raise ValueError(f'Path is outside this repository: {value}')
    path = absolute.relative_to(root.resolve())
    names = {name for name, spec in areas.items()
             if path.is_relative_to(spec['path']) or Path(spec['path']).is_relative_to(path)
             or path.as_posix() in [spec['guide'], *spec.get('entryPoints', [])]}
    if path.as_posix() in GLOBAL_INPUTS or path.is_relative_to('trip.xcodeproj'):
        names.update(areas)
    if path.is_relative_to('Packages/TripKit/Tests'):
        names.update(name for name in areas if path.is_relative_to(f'Packages/TripKit/Tests/{name}Tests'))
    if path.is_relative_to('TripAppTests') or path.as_posix() == 'TestPlans/TripModels.xctestplan':
        names.update({'App'} & areas.keys())
    return path.as_posix(), names


def impact(root, paths=(), base=None, head='HEAD'):
    areas = catalog(root)
    selected = list(paths) + (changed_paths(root, base, head) if base or not paths else [])
    mapped, direct, unowned = {}, set(), []
    for value in selected:
        path, owners = owners_for_path(root, value, areas)
        mapped[path] = sorted(owners)
        direct.update(owners)
        if not owners:
            unowned.append(path)
    affected, frontier = set(direct), set(direct)
    while frontier:
        consumers = {name for name, spec in areas.items()
                     if frontier.intersection(spec.get('dependencies', []) + spec.get('packages', []))}
        frontier = consumers - affected
        affected.update(frontier)
    return {
        'schemaVersion': 1, 'basis': {'base': base, 'head': revision(root, head) if base else None,
                                    'mode': 'merge-base-to-head' if base else 'paths' if paths else 'working-tree-and-index'},
        'paths': dict(sorted(mapped.items())), 'directOwners': sorted(direct),
        'affectedOwners': sorted(affected), 'unownedPaths': sorted(set(unowned)),
        'contextCommands': [f'python3 scripts/workspace.py context {name} --json' for name in sorted(direct)],
        'guides': sorted({areas[name]['guide'] for name in affected}),
        'verification': suggestions(root, affected, unowned),
        'limitations': 'Conservative declared dependencies, not symbol-level impact. Unowned paths need manual review. Commands are suggestions, not executed checks.',
    }


def package_test_suites(root, owners):
    source = (root / 'Packages/TripKit/Package.swift').read_text()
    declarations = re.findall(r'\.testTarget\(name:\s*"(\w+)",\s*dependencies:\s*\[([^\]]*)\]', source)
    return sorted(name for name, dependencies in declarations
                  if owners.intersection(re.findall(r'"(\w+)"', dependencies)))


def suggestions(root, owners, unowned):
    result = [{'kind': 'source', 'command': 'bash scripts/check.sh'}]
    if unowned:
        result.append({'kind': 'review', 'command': None, 'reason': 'Review unowned resource, documentation, and tooling paths.'})
    if any(path.startswith('scripts/') for path in unowned):
        result.append({'kind': 'tooling', 'command': "python3 -m unittest discover -s scripts -p 'test_*.py'"})
    suites = package_test_suites(root, owners)
    if suites:
        result.append({'kind': 'executable', 'command': 'bash scripts/test.sh package', 'affectedTestTargets': suites})
    if owners.intersection({'App', 'Trips'}):
        result.append({'kind': 'executable',
                       'command': "bash scripts/test.sh models 'platform=iOS Simulator,id=<simulator-UDID>'",
                       'affectedTestTargets': ['TripAppTests'], 'requiresExplicitDestination': True})
    if owners.intersection({'TripDomain', 'MapEngine', 'Explore', 'System'}) or any(path.startswith('Performance/') for path in unowned):
        result.append({'kind': 'executable', 'command': 'bash scripts/performance.sh check'})
    if owners - {'PreviewSupport'}:
        result.append({'kind': 'compilation', 'command': 'bash scripts/build.sh app Debug'})
        result.append({'kind': 'compilation', 'command': 'bash scripts/build.sh visionOS Debug'})
    return result
