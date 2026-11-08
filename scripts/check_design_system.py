#!/usr/bin/env python3
"""Source-only Trip visual policy checks; never builds, launches, or renders the app."""
import json
import re
import sys
from pathlib import Path
from source_text import production_mask

ROOT = Path(__file__).resolve().parent.parent
POLICY = json.loads((ROOT / "scripts/design_system_policy.json").read_text())
PATTERNS = {
    "fixed_font": r"\.font\s*\(\s*\.system\s*\(\s*size\s*:",
    "raw_spacing": r"\bspacing:\s*(?:[1-9]\d*(?:\.\d+)?|0\.\d*[1-9]\d*)\b",
    "raw_inset": r"\.padding\(\s*(?:\.\w+\s*,\s*)?(?:[1-9]\d*(?:\.\d+)?|0\.\d*[1-9]\d*)\s*\)",
    "literal_motion": r"\.(?:smooth|snappy|bouncy|easeInOut|easeIn|easeOut|linear|spring)\s*\(\s*(?:duration|response):\s*\d",
    "literal_color": r"Color\s*\(\s*(?:red|hue|white)\s*:",
    "warning_color": r"\.foregroundStyle\s*\(\s*\.(?:orange|red)\s*\)",
    "repeating_motion": r"\.repeatForever\s*\(",
}
GUIDANCE = {
    "fixed_font": "Use a semantic text style; fixed annotation/glyph geometry needs a documented exception.",
    "raw_spacing": "Use the owning AppTheme, WidgetTheme, or DirectionsSpacing token.",
    "raw_inset": "Use a spacing token; map clearance needs a documented geometry exception.",
    "literal_motion": "Use AppTheme.Motion for ordinary controls, with the Reduce Motion value.",
    "literal_color": "Use semantic system colors or adaptive assets; review package-owned exceptions.",
    "warning_color": "Use TripWarningLabel or a semantic primary label plus an explanatory symbol.",
    "repeating_motion": "Trip status feedback is finite; native progress controls own continuous loading feedback.",
}
VARIANTS = {(False, False), (True, False), (False, True), (True, True)}


def policy_paths(root, policy):
    errors, files = [], set()
    roots = policy.get('roots', [])
    if not isinstance(roots, list) or not roots:
        return ['Design policy roots must be a nonempty list.'], []
    for name in roots:
        if not isinstance(name, str):
            errors.append(f'Invalid design policy root: {name}')
            continue
        path = (root / name).resolve()
        if not path.is_relative_to(root.resolve()) or not path.is_dir():
            errors.append(f'Invalid design policy root: {name}')
        else:
            files.update(path.rglob('*.swift'))
    return errors, sorted(files)


def scoped_exceptions(root, policy, files):
    errors, scopes = [], {}
    names = {path.relative_to(root).as_posix() for path in files}
    exceptions = policy.get('exceptions', {})
    if not isinstance(exceptions, dict):
        return ['Design exceptions must be a rule map.'], {}
    for rule, entries in exceptions.items():
        if rule not in PATTERNS:
            errors.append(f'Unknown design exception rule: {rule}')
        if not isinstance(entries, dict):
            errors.append(f'Design exceptions must map paths to scopes: {rule}')
            continue
        for name, entry in entries.items():
            if name not in names or not isinstance(entry, dict) or not isinstance(entry.get('reason'), str) or not entry['reason'].strip():
                errors.append(f'Invalid scoped design exception: {rule}: {name}')
                continue
            occurrences = entry.get('occurrences', [])
            if not isinstance(occurrences, list) or not occurrences:
                errors.append(f'Design exception needs exact code occurrences: {rule}: {name}')
                continue
            for occurrence in occurrences:
                if not isinstance(occurrence, dict):
                    errors.append(f'Invalid design occurrence: {rule}: {name}')
                    continue
                code, count = occurrence.get('code'), occurrence.get('count')
                if not isinstance(code, str) or not code.strip() or '\n' in code or type(count) is not int or count < 1:
                    errors.append(f'Invalid design occurrence: {rule}: {name}')
                elif (rule, name, code) in scopes:
                    errors.append(f'Duplicate design occurrence: {rule}: {name}: {code}')
                else:
                    scopes[(rule, name, code)] = count
    return errors, scopes


def geometry_errors(root, policy, files):
    errors = []
    names = {path.relative_to(root).as_posix() for path in files}
    notes = policy.get('geometry_notes', {})
    if not isinstance(notes, dict):
        return ['Geometry notes must map paths to reasons and anchors.']
    for name, entry in notes.items():
        if name not in names or not isinstance(entry, dict) or not isinstance(entry.get('reason'), str) or not entry['reason'].strip():
            errors.append(f'Invalid geometry note: {name}')
            continue
        source = production_mask((root / name).read_text())
        anchors = entry.get('anchors', [])
        if not isinstance(anchors, list) or not anchors or any(not isinstance(anchor, str) or not anchor.strip() or anchor not in source for anchor in anchors):
            errors.append(f'Geometry note needs current production code anchors: {name}')
    return errors


def source_errors(root=None, policy=None):
    root, policy = (root or ROOT).resolve(), POLICY if policy is None else policy
    errors, files = policy_paths(root, policy)
    invalid, remaining = scoped_exceptions(root, policy, files)
    errors += invalid + geometry_errors(root, policy, files)
    for path in files:
        name = path.relative_to(root).as_posix()
        original = path.read_text()
        lines = original.splitlines()
        source = production_mask(original)
        for rule, pattern in PATTERNS.items():
            for match in re.finditer(pattern, source):
                line = source.count("\n", 0, match.start()) + 1
                key = (rule, name, lines[line - 1].strip())
                if remaining.get(key, 0):
                    remaining[key] -= 1
                    continue
                errors.append(f"{name}:{line}: {GUIDANCE[rule]}")
    errors += [f'Remove unused design occurrence: {rule}: {name}: {code} ({count} remaining)'
               for (rule, name, code), count in remaining.items() if count]
    return errors, len(files)


def spacing_errors():
    """Independent targets keep local constants but share Trip's reviewed numerical scale."""
    pattern = r"static let (\w+): CGFloat = (\d+)"
    paths = ["trip/DesignSystem/AppTheme.swift", "TripWidgets/DesignSystem/WidgetTheme.swift",
             "Packages/TripKit/Sources/TripRouting/Feature/Models/DirectionsSpacing.swift"]
    values = [dict(re.findall(pattern, (ROOT / path).read_text())) for path in paths]
    errors = []
    for path, tokens in zip(paths[1:], values[1:]):
        for name, value in tokens.items():
            if value != values[0].get(name):
                errors.append(f"{path}: spacing {name}={value} disagrees with AppTheme.")
    expected = {"compact": "2", "tight": "4", "small": "8", "medium": "12", "large": "16", "edge": "20"}
    for name, value in expected.items():
        if values[0].get(name) != value:
            errors.append(f"AppTheme spacing {name} must be {value}; revise the visual contract before changing the scale.")
    return errors


def luminance(rgb):
    linear = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in rgb]
    return sum(v * weight for v, weight in zip(linear, (0.2126, 0.7152, 0.0722)))


def contrast(first, second):
    lower, upper = sorted((luminance(first), luminance(second)))
    return (upper + 0.05) / (lower + 0.05)


def palette_errors():
    errors, ratios = [], []
    assets = sorted((ROOT / "trip/DesignSystem/Colors.xcassets").glob("*.colorset/Contents.json"))
    required = {"AccentColor", "AccentFill", "RatingColor"}
    missing = required - {path.parent.stem for path in assets}
    errors.extend(f"Missing required palette asset: {name}" for name in sorted(missing))
    theme = (ROOT / "trip/DesignSystem/AppTheme.swift").read_text()
    if not re.search(r"static let onAccentFill\s*=\s*Color\.white\b", theme):
        errors.append("Update the palette contract/check before changing the white onAccentFill foreground.")
    for path in assets:
        name = path.parent.stem
        variants, measured = set(), {}
        fill = name == "AccentFill" or name.startswith("PlaceMarker-")
        for entry in json.loads(path.read_text())["colors"]:
            appearance = {v["appearance"]: v["value"] for v in entry.get("appearances", [])}
            key = (appearance.get("luminosity") == "dark", appearance.get("contrast") == "high")
            if key in variants:
                errors.append(f"{name}: duplicate appearance {key}.")
            variants.add(key)
            color = entry["color"]
            components = color["components"]
            rgb = [float(components[c]) for c in ("red", "green", "blue")]
            if color["color-space"] != "srgb" or float(components["alpha"]) != 1 or any(v < 0 or v > 1 for v in rgb):
                errors.append(f"{name}: palette checks require opaque sRGB components in 0...1.")
                continue
            background = (0, 0, 0) if key[0] else (1, 1, 1)
            pairs = [contrast((1, 1, 1), rgb)] if fill else [contrast(rgb, background)]
            if not fill:
                wash = [v * 0.12 + b * 0.88 for v, b in zip(rgb, background)]
                pairs.append(contrast(rgb, wash))
            measured[key] = min(pairs)
            ratios.extend(pairs)
            if min(pairs) < 4.5:
                errors.append(f"{name} {key}: reference contrast {min(pairs):.2f}:1 is below 4.5:1.")
        if variants != VARIANTS:
            errors.append(f"{name}: requires light, dark, and both increased-contrast variants.")
        for dark in (False, True):
            if measured.get((dark, True), 0) < measured.get((dark, False), 0):
                errors.append(f"{name}: increased contrast must not reduce the measured contrast.")
    if not assets:
        errors.append("No design palette assets found.")
    return errors, len(assets), min(ratios, default=0)


def main():
    source, files = source_errors()
    palette, colors, minimum = palette_errors()
    errors = source + spacing_errors() + palette
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"Design policy checked {files} Swift sources and {colors} adaptive colors; minimum reference contrast {minimum:.2f}:1.")
    print("Source and solid-color reference checks only; rendered materials, Dynamic Type, and motion require UI review.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
