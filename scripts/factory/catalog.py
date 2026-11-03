"""Human and machine context from the same manifests that enforce ownership."""
import json
from pathlib import Path
from .skills import check_routes, selection

REQUIRED_READING = ["AGENTS.md", "ARCHITECTURE.md", "CONTRIBUTING.md", "docs/Skills.md"]


def catalog(root):
    owners = json.loads((root / "scripts/architecture/app-ownership.json").read_text())
    modules = json.loads((root / "Packages/TripKit/modules.json").read_text())
    result = {name: dict(spec, kind="source") for name, spec in owners.items()}
    for name, dependencies in modules.items():
        result[name] = {
            "kind": "package", "path": f"Packages/TripKit/Sources/{name}",
            "dependencies": dependencies, "guide": "Packages/TripKit/README.md",
            "purpose": "Reusable package; public contracts require consumer review",
            "entryPoints": ["Packages/TripKit/Package.swift"],
        }
    result["PreviewSupport"] = {
        "kind": "preview", "path": "trip/PreviewSupport", "dependencies": list(owners),
        "guide": "docs/PreviewSupport.md", "purpose": "DEBUG-only local composition and fixtures",
        "entryPoints": ["trip/PreviewSupport/PreviewTripServices.swift"],
    }
    return result


def context(root, name):
    areas = catalog(root)
    if name not in areas:
        raise ValueError(f"Unknown area {name!r}. Run 'python3 scripts/workspace.py list'.")
    spec = areas[name]
    dependents = sorted(key for key, value in areas.items()
                        if name in value.get("dependencies", []) + value.get("packages", []))
    dependencies = spec.get("dependencies", []) + spec.get("packages", [])
    return dict(name=name, **spec, dependents=dependents,
                sourceFiles=sorted(str(path.relative_to(root)) for path in (root / spec["path"]).rglob("*.swift")),
                requiredReading=[*REQUIRED_READING, spec["guide"]],
                dependencyGuides={owner: areas[owner]["guide"] for owner in dependencies},
                skills=selection(root, name, spec["kind"]),
                verification={"source": "bash scripts/check.sh", "build": "Only when requested",
                              "runtime": "Separate from source audits and compilation"})


def locate(root, value):
    path = Path(value)
    path = (path if path.is_absolute() else root / path).resolve()
    if not path.is_relative_to(root.resolve()):
        raise ValueError("Path is outside this repository.")
    relative = path.relative_to(root.resolve())
    matches = [name for name, spec in catalog(root).items() if relative.is_relative_to(spec["path"])]
    if len(matches) != 1:
        raise ValueError(f"Expected one source owner for {relative}; found {matches}. Run workspace.py list.")
    return {"path": str(relative), "owner": matches[0],
            "contextCommand": f"python3 scripts/workspace.py context {matches[0]} --json"}


def check_catalog(root):
    areas = catalog(root)
    errors = check_routes(root, areas)
    for path in REQUIRED_READING:
        if not (root / path).is_file():
            errors.append(f"Missing required context: {path}")
    for name, spec in areas.items():
        for value in [spec["path"], spec["guide"], *spec.get("entryPoints", [])]:
            path = root / value
            if not path.resolve().is_relative_to(root.resolve()):
                errors.append(f"{name}: workspace reference escapes repository {value}")
            elif not path.exists():
                errors.append(f"{name}: missing workspace reference {value}")
        for owner in spec.get("dependencies", []) + spec.get("packages", []):
            if owner not in areas:
                errors.append(f"{name}: unknown context dependency {owner}")
    return errors
