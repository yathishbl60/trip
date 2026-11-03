"""Small explicit scaffolder; no navigation wiring, service locator, or runtime discovery."""
import json
import os
from pathlib import Path
import re
from string import Template
import tempfile
from .catalog import catalog

TEMPLATES = Path(__file__).resolve().parents[2] / "templates/feature"


def plan(root, name, purpose):
    if not re.fullmatch(r"[A-Z][A-Za-z0-9]{1,39}", name):
        raise ValueError("Use a 2–40 character UpperCamelCase name containing only letters and digits.")
    if not purpose.strip() or len(purpose) > 300 or "\n" in purpose or "\r" in purpose:
        raise ValueError("Supply a one-line user purpose of 1–300 characters.")
    if name.casefold() in {area.casefold() for area in catalog(root)}:
        raise ValueError(f"Area {name!r} already exists.")
    # Avoid colliding with existing types, including extension-only declarations.
    for directory in ("trip", "TripWidgets", "Packages/TripKit/Sources"):
        for path in (root / directory).rglob("*.swift"):
            if re.search(rf"\b{name}(?:Model|Controller|RootView)\b", path.read_text()):
                raise ValueError(f"Feature type already referenced in {path.relative_to(root)}")
    base = f"trip/Features/{name}"
    files = {}
    for role, suffix in (("Models", "Model"), ("Controllers", "Controller"), ("Views", "RootView")):
        template = Template((TEMPLATES / f"{suffix}.swift.template").read_text())
        files[f"{base}/{role}/{name}{suffix}.swift"] = template.substitute(feature=name)
    guide = f"docs/features/{name}.md"
    files[guide] = Template((TEMPLATES / "Guide.md.template").read_text()).substitute(feature=name, purpose=purpose)
    manifest = "scripts/architecture/app-ownership.json"
    original = (root / manifest).read_bytes()
    owners = json.loads(original)
    owners[name] = {"path": base, "dependencies": ["DesignSystem"], "packages": ["TripDomain", "TripLocalization"],
                   "forbiddenImports": ["SwiftData", "FoundationModels"], "purpose": purpose.strip(),
                   "guide": guide, "entryPoints": [f"{base}/Views/{name}RootView.swift"]}
    owners["App"]["dependencies"].append(name)
    for relative in [base, *files]:
        path = root / relative
        if not path.resolve().is_relative_to(root.resolve()):
            raise ValueError(f"Destination escapes the repository: {relative}")
        if path.exists() or path.is_symlink():
            raise ValueError(f"Refusing to overwrite {relative}")
    return files, manifest, original, json.dumps(owners, indent=2) + "\n"


def scaffold(root, name, purpose, write=False):
    files, manifest, original, updated = plan(root, name, purpose)
    if write:
        create_files(root, files, manifest, original, updated)
    verb = "Created" if write else "Would create"
    lines = [f"{verb} {path}" for path in files]
    lines += [f"{'Updated' if write else 'Would update'} {manifest}",
              "The starter displays injected state only; implement the task before adding an App entry point.",
              f"Next: python3 scripts/workspace.py context {name} --json (after creation).",
              "Review the guide, implement acceptance cases, wire composition, and run bash scripts/check.sh."]
    if not write:
        lines.append("Dry run: no files changed. Add --write to create the feature.")
    return "\n".join(lines)


def create_files(root, files, manifest, original, updated):
    created, directories = [], []
    temporary = None
    destination = root / manifest
    try:
        if destination.read_bytes() != original:
            raise ValueError("Ownership changed after planning; review the change and rerun scaffolding.")
        for relative, content in files.items():
            path = root / relative
            missing = []
            parent = path.parent
            while not parent.exists():
                missing.append(parent)
                parent = parent.parent
            path.parent.mkdir(parents=True, exist_ok=True)
            directories.extend(reversed(missing))
            with path.open("x", encoding="utf-8") as output:
                identity = os.fstat(output.fileno())
                record = {"path": path, "identity": (identity.st_dev, identity.st_ino),
                          "content": content.encode("utf-8"), "complete": False}
                created.append(record)
                output.write(content)
            record["complete"] = True
        with tempfile.NamedTemporaryFile(mode="w", dir=destination.parent, delete=False) as output:
            temporary = Path(output.name)
            output.write(updated)
        temporary.chmod(destination.stat().st_mode & 0o777)
        if destination.read_bytes() != original:
            raise ValueError("Ownership changed during scaffolding; review the change and rerun.")
        os.replace(temporary, destination)
    except (OSError, ValueError) as error:
        retained = rollback(created, directories)
        if retained:
            paths = ", ".join(str(path.relative_to(root)) for path in retained)
            raise ValueError(f"{error}\nRetained changed or incomplete files for review: {paths}") from error
        raise
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def rollback(created, directories):
    retained = []
    for record in reversed(created):
        path = record["path"]
        try:
            current = path.lstat()
            same_file = (current.st_dev, current.st_ino) == record["identity"]
            if record["complete"] and same_file and not path.is_symlink() and path.read_bytes() == record["content"]:
                path.unlink()
            else:
                retained.append(path)
        except FileNotFoundError:
            pass
        except OSError:
            retained.append(path)
    for directory in reversed(directories):
        try:
            directory.rmdir()
        except OSError:
            pass  # Retain concurrent content and files reported above.
    return retained
