"""Conditional skill routes; global installations are optional and never inspected."""
import json
import re


def routes(root):
    configured = json.loads((root / "scripts/factory/skill-routes.json").read_text())
    if not isinstance(configured, dict) or set(configured) != {"defaults", "owners"}:
        raise ValueError("Skill routes must contain defaults and owners maps.")
    for group, entries in configured.items():
        if not isinstance(entries, dict):
            raise ValueError(f"Skill routes {group} must be a map.")
        for name, candidates in entries.items():
            if not isinstance(candidates, list):
                raise ValueError(f"Skill routes for {name} must be a list.")
            for item in candidates:
                if not isinstance(item, dict) or set(item) != {"when", "project", "global"}:
                    raise ValueError(f"Each {name} route must define when, project, and global.")
                if not isinstance(item["when"], str) or not item["when"].strip():
                    raise ValueError(f"{name}: skill route needs a selection condition.")
                for scope in ("project", "global"):
                    values = item[scope]
                    if not isinstance(values, list) or any(not isinstance(value, str) for value in values):
                        raise ValueError(f"{name}: {scope} skills must be a list of names.")
                    if len(values) != len(set(values)):
                        raise ValueError(f"{name}: duplicate {scope} skill route.")
    return configured


def selection(root, name, kind):
    configured = routes(root)
    candidates = configured["owners"].get(name, configured["defaults"][kind])
    return {
        "instruction": "Choose only candidates matching the actual task; these are not mandatory bulk reading.",
        "workflow": {"name": "app-development", "scope": "global", "when": "Implementing a feature across contracts, state, UI, and integration"},
        "candidates": [dict(item, projectPaths=[f".agents/skills/{skill}/SKILL.md" for skill in item["project"]])
                       for item in candidates],
        "globalFallback": "If unavailable, use project contracts, installed SDK declarations, and current Apple documentation; do not vendor global skills.",
    }


def check_routes(root, owners):
    configured = routes(root)
    errors = []
    for name in set(configured["owners"]) - set(owners):
        errors.append(f"Skill route has unknown owner: {name}")
    if set(configured["defaults"]) != {"source", "package", "preview"}:
        errors.append("Skill routes must define source, package, and preview defaults")
    for group in (configured["defaults"], configured["owners"]):
        for name, candidates in group.items():
            for item in candidates:
                for scope in ("project", "global"):
                    for skill in item.get(scope, []):
                        if not re.fullmatch(r"[a-z][a-z0-9-]*", skill):
                            errors.append(f"{name}: invalid skill name {skill!r}")
                        if scope == "project":
                            entry = root / f".agents/skills/{skill}/SKILL.md"
                            if not entry.is_file():
                                errors.append(f"{name}: missing project skill {skill}")
                            elif not entry.resolve().is_relative_to(root.resolve()) or entry.is_symlink() or entry.parent.is_symlink():
                                errors.append(f"{name}: project skill must be an owned repository file: {skill}")
                        if (scope == "project") != skill.startswith("trip-"):
                            errors.append(f"{name}: {skill} has incorrect {scope} scope")
                        if scope == "global" and skill != "app-development":
                            errors.append(f"{name}: use the unified global app-development skill, not retired or competing route {skill}")
    return errors
