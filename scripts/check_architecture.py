"""Check module boundaries and source manifests without compiling the app."""
import json
import pathlib
import subprocess
from architecture.feature_boundaries import check_features, check_package_app_references
from architecture.system_surfaces import check_system_surfaces
from architecture.manifest_contracts import check_compiler_settings, check_package_manifest
from architecture.swift_sources import IMPORTS, code_only

ROOT = pathlib.Path(__file__).resolve().parents[1]
PACKAGE = ROOT / "Packages/TripKit"
GRAPH = json.loads((PACKAGE / "modules.json").read_text())


def check_sources():
    errors = []
    directories = {path.name for path in (PACKAGE / "Sources").iterdir() if path.is_dir()}
    if directories != GRAPH.keys():
        errors.append("Package source directories disagree with modules.json")
    for module, dependencies in GRAPH.items():
        sources = list((PACKAGE / "Sources" / module).rglob("*.swift"))
        if not sources:
            errors.append(f"Empty module: {module}")
        for path in sources:
            text = code_only(path.read_text())
            forbidden = (set(IMPORTS.findall(text)) & GRAPH.keys()) - set(dependencies)
            if forbidden:
                errors.append(f"{path.relative_to(ROOT)} imports {sorted(forbidden)}")
            if module == "TripDomain" and set(IMPORTS.findall(text)) & {"SwiftUI", "SwiftData", "FoundationModels"}:
                errors.append(f"{path.relative_to(ROOT)} adds a presentation or service dependency to domain")
    return errors


def check_graph():
    errors, visited, pending = [], set(), set()

    def visit(module):
        if module in pending or module not in GRAPH:
            errors.append(f"Cyclic or unknown module dependency: {module}")
            return
        if module in visited:
            return
        pending.add(module)
        for dependency in GRAPH[module]:
            visit(dependency)
        pending.remove(module)
        visited.add(module)

    for module in GRAPH:
        visit(module)
    return errors


def check_manifests():
    errors = []
    manifest = (PACKAGE / "Package.swift").read_text()
    errors += check_package_manifest(manifest, GRAPH)
    for name in (ROOT / "Performance/sources.txt").read_text().splitlines():
        if name and not name.startswith("#") and not (ROOT / name).is_file():
            errors.append(f"Missing performance source: {name}")
    output = subprocess.check_output(["plutil", "-convert", "json", "-o", "-",
                                     str(ROOT / "trip.xcodeproj/project.pbxproj")], text=True)
    objects = json.loads(output)["objects"]
    errors += check_compiler_settings(objects)
    products = {value.get("productName") for value in objects.values()
                if value.get("isa") == "XCSwiftPackageProductDependency"}
    if products != GRAPH.keys():
        errors.append("The app's linked package products disagree with modules.json")
    errors += check_system_surfaces(ROOT, objects)
    return errors


if __name__ == "__main__":
    errors = check_graph() + check_sources() + check_manifests()
    errors += check_features(ROOT, set(GRAPH)) + check_package_app_references(ROOT, PACKAGE)
    for error in errors:
        print(error)
    print(f"Checked {len(GRAPH)} package modules, app source ownership, and source manifests.")
    raise SystemExit(bool(errors))
