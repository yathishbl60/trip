"""Enforce source ownership inside the app's single binary target."""
import json
from .swift_sources import DECLARATIONS, IDENTIFIERS, IMPORTS, declared_types, production_source


def check_features(root, packages):
    ownership = json.loads((root / "scripts/architecture/app-ownership.json").read_text())
    sources = {name: list((root / spec["path"]).rglob("*.swift")) for name, spec in ownership.items()}
    types = {name: declared_types(paths) for name, paths in sources.items()}
    preview_types = declared_types((root / "trip/PreviewSupport").rglob("*.swift"))
    errors = check_ownership(root, ownership, sources)
    for owner, paths in sources.items():
        unknown = set(ownership[owner]["packages"]) - packages
        if unknown:
            errors.append(f"Unknown packages in {owner}: {sorted(unknown)}")
        allowed = {owner, *ownership[owner]["dependencies"]}
        forbidden_types = set().union(*(names for area, names in types.items() if area not in allowed))
        forbidden_types -= set().union(*(types.get(area, set()) for area in allowed))
        for path in paths:
            code = production_source(path.read_text())
            references = set(IDENTIFIERS.findall(code))
            invalid = references & (forbidden_types | preview_types)
            used_imports = set(IMPORTS.findall(code))
            imports = (used_imports & packages) - set(ownership[owner]["packages"])
            imports |= used_imports & set(ownership[owner].get("forbiddenImports", []))
            label = path.relative_to(root)
            if invalid:
                errors.append(f"{label} crosses {owner}'s source boundary: {', '.join(sorted(invalid))}")
            if imports:
                errors.append(f"{label} imports packages outside {owner}'s contract: {sorted(imports)}")
            if {"UIKit", "UIImage", "UIViewRepresentable", "UIViewControllerRepresentable"} & references:
                errors.append(f"{label} introduces forbidden UIKit usage")
    return errors


def check_ownership(root, ownership, sources):
    errors, covered = [], set()
    for owner, paths in sources.items():
        if not paths:
            errors.append(f"Empty source owner: {owner}")
        for dependency in ownership[owner]["dependencies"]:
            if dependency not in ownership:
                errors.append(f"Unknown dependency {dependency} in {owner}")
        for path in set(paths) & covered:
            errors.append(f"Swift source has overlapping owners: {path.relative_to(root)}")
        covered.update(paths)
    actual = set((root / "trip").rglob("*.swift")) - set((root / "trip/PreviewSupport").rglob("*.swift"))
    actual.update((root / "TripWidgets").rglob("*.swift"))
    for path in actual - covered:
        errors.append(f"Swift source has no owner: {path.relative_to(root)}")
    for owner in ownership:
        visit_dependencies(owner, ownership, set(), errors)
    return errors


def visit_dependencies(owner, ownership, pending, errors):
    if owner in pending:
        errors.append(f"Cyclic feature dependency: {' -> '.join([*sorted(pending), owner])}")
        return
    for dependency in ownership[owner]["dependencies"]:
        if dependency in ownership:
            visit_dependencies(dependency, ownership, pending | {owner}, errors)


def check_package_app_references(root, package):
    app_types = declared_types((root / "trip").rglob("*.swift"))
    errors = []
    for path in (package / "Sources").rglob("*.swift"):
        code = production_source(path.read_text())
        own_types = set(DECLARATIONS.findall(code))
        forbidden = (set(IDENTIFIERS.findall(code)) - own_types) & app_types
        if forbidden:
            errors.append(f"{path.relative_to(root)} refers to app types: {sorted(forbidden)}")
    return errors
