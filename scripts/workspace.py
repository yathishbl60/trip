"""Discover ownership, export focused AI context, or scaffold a native VCM feature."""
import argparse
import json
from pathlib import Path
from factory.catalog import catalog, check_catalog, context, locate
from factory.scaffold import scaffold
from factory.impact import impact
from factory.doctor import doctor
from factory.metrics import metrics

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    listing = commands.add_parser("list", help="List feature, shared, and package owners")
    listing.add_argument("--json", action="store_true")
    focused = commands.add_parser("context", help="Show an area's contracts, consumers, and source paths")
    focused.add_argument("area")
    focused.add_argument("--json", action="store_true")
    owner = commands.add_parser("locate", help="Find the exact source owner for a repository file or directory")
    owner.add_argument("path")
    owner.add_argument("--json", action="store_true")
    commands.add_parser("check", help="Validate documentation and entry-point references")
    changes = commands.add_parser('impact', help='Show conservative owners and consumers for paths or a Git change range')
    changes.add_argument('paths', nargs='*', help='Repository paths; defaults to working tree, index, and untracked changes')
    changes.add_argument('--base', help='Compare merge-base(base, head) through head')
    changes.add_argument('--head', default='HEAD')
    changes.add_argument('--json', action='store_true')
    environment = commands.add_parser('doctor', help='Read prerequisites, SDK versions, schemes, and output paths without building')
    environment.add_argument('--json', action='store_true')
    environment.add_argument('--require-ready', action='store_true', help='Exit nonzero unless source and compilation prerequisites are available')
    inventory = commands.add_parser('metrics', help='Advisory physical-file and logical-type inventory; not a quality gate')
    inventory.add_argument('--owner')
    inventory.add_argument('--json', action='store_true')
    new = commands.add_parser("scaffold", help="Preview a new VCM feature; --write explicitly creates it")
    new.add_argument("name", help="UpperCamelCase name, for example Journal")
    new.add_argument("--purpose", required=True, help="The user task this feature serves")
    new.add_argument("--write", action="store_true", help="Create sources, guide, and ownership entry")
    args = parser.parse_args()
    if args.command == 'impact' and args.head != 'HEAD' and not args.base:
        parser.error('--head requires --base')
    try:
        execute(args)
    except (ValueError, OSError, KeyError) as error:
        parser.exit(1, f"workspace: {error}\n")


def execute(args):
    if args.command in {'impact', 'doctor', 'metrics'}:
        if args.command == 'impact':
            result = impact(ROOT, args.paths, args.base, args.head)
        elif args.command == 'doctor':
            result = doctor(ROOT)
        else:
            result = metrics(ROOT, args.owner)
        print(json.dumps(result, indent=2) if args.json else report(args.command, result))
        if args.command == 'doctor' and args.require_ready and not result['readyForCompilation']:
            raise ValueError('Source or compilation prerequisites are missing; inspect the doctor report above.')
    elif args.command == "check":
        errors = check_catalog(ROOT)
        if errors:
            raise ValueError("\n".join(errors))
        print("Workspace guides and entry points are current.")
    elif args.command == "locate":
        result = locate(ROOT, args.path)
        print(json.dumps(result, indent=2) if args.json else f"{result['path']} → {result['owner']}\n{result['contextCommand']}")
    elif args.command == "scaffold":
        print(scaffold(ROOT, args.name, args.purpose, write=args.write))
    elif args.command == "list":
        areas = catalog(ROOT)
        if args.json:
            print(json.dumps(areas, indent=2))
        else:
            for name, spec in areas.items():
                print(f"{name:26} {spec['path']}\n  {spec['purpose']}")
    else:
        result = context(ROOT, args.area)
        if args.json:
            print(json.dumps(result, indent=2))
        else:
            print(f"{result['name']}: {result['purpose']}\nOwner: {result['path']}")
            for key in ("requiredReading", "entryPoints", "dependencies", "packages", "dependents", "sourceFiles"):
                print(f"{key}:\n" + "\n".join(f"  {item}" for item in result.get(key, [])))
            print("Conditional skills (select only those relevant to this task):")
            for route in result["skills"]["candidates"]:
                print(f"  {route['when']}: {', '.join(route['project'] + route['global'])}")
            print("Verification: bash scripts/check.sh; builds and runtime checks only when requested.")


def report(command, result):
    if command == 'impact':
        return '\n'.join([f"Direct owners: {', '.join(result['directOwners']) or '(none)'}",
                          f"Affected owners: {', '.join(result['affectedOwners']) or '(none)'}",
                          f"Unowned paths: {', '.join(result['unownedPaths']) or '(none)'}",
                          *result['contextCommands'], result['limitations']])
    if command == 'doctor':
        return '\n'.join([f"Source prerequisites ready: {result['readyForSourceChecks']}",
                          f"Compilation prerequisites ready: {result['readyForCompilation']}",
                          *(f"{name}: {'available' if ready else 'missing'}" for name, ready in result['prerequisites'].items()),
                          *(f"{name}: {value['output']} (minimum {value['required']})" for name, value in result['sdks'].items()),
                          result['limitations'], 'Use --json for complete toolchain, scheme, and output information.'])
    return '\n'.join([*(f"{row['owner']}: {row['files']} files, {row['physicalLines']} lines" for row in result['owners']),
                      'Largest logical type families:',
                      *(f"{row['owner']}.{row['type']}: {row['fileCount']} files, {row['extensions']} extensions" for row in result['logicalTypes'][:15]),
                      result['limitations']])


if __name__ == "__main__":
    main()
