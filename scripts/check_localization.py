"""Audit catalog coverage, placeholder types, and generated localization resources."""
import collections
import json
import re
from pathlib import Path
from generate_localization import CATALOG, DESTINATION, ROOT, generate, is_current
from architecture.localization_resources import check_native_keys, check_resources, extraction_artifact

FORMAT = re.compile(r"%(?:(\d+)\$)?(@|lld)")
TOKENS = re.compile(r"\$\{\w+\}")


def units(localization):
    if "stringUnit" in localization:
        return [localization["stringUnit"]]
    plural = localization["variations"]["plural"]
    assert {"one", "other"} <= plural.keys(), "Missing required plural variants"
    return [value["stringUnit"] for value in plural.values()]


def placeholders(value):
    matches = FORMAT.findall(value)
    return sorted((int(position) if position else index, kind)
                  for index, (position, kind) in enumerate(matches, 1))


def format_only_entry(key, entry):
    if "@symbol " in entry.get("comment", "") or FORMAT.sub("", key):
        return False
    return all(not FORMAT.sub("", unit["value"])
               for localization in entry.get("localizations", {}).values()
               for unit in units(localization))


def check_catalog(path):
    catalog = json.loads(path.read_text())
    assert catalog["sourceLanguage"] == "en", path
    review = collections.Counter()
    for key, entry in catalog["strings"].items():
        if format_only_entry(key, entry) or extraction_artifact(key, entry):
            continue
        assert "localizations" in entry, (path, key, "Missing language")
        localizations = entry["localizations"]
        assert {"en", "hi", "kn"} <= localizations.keys(), (path, key, "Missing language")
        english = units(localizations["en"])[-1]["value"]
        expected, tokens = placeholders(english), sorted(TOKENS.findall(english))
        for language, localization in localizations.items():
            for unit in units(localization):
                value = unit["value"]
                assert value and unit["state"] in {"translated", "needs_review"}, (key, language)
                assert placeholders(value) == expected, (path, key, language, "Placeholder mismatch")
                assert sorted(TOKENS.findall(value)) == tokens, (path, key, language, "Siri token mismatch")
                if unit["state"] == "needs_review":
                    review[language] += 1
    return len(catalog["strings"]), review


def main():
    for path, text in generate().items():
        assert is_current(path, text), f"Stale generated localization: {path}"
    catalogs = [CATALOG, *sorted((DESTINATION / "HostResources").glob("*.xcstrings"))]
    for path in catalogs:
        count, review = check_catalog(path)
        print(f"{path.relative_to(DESTINATION)}: {count} keys; en/hi/kn complete; review units {dict(review)}")
    check_resources(ROOT, DESTINATION)
    native = json.loads((DESTINATION / "HostResources/Localizable.xcstrings").read_text())["strings"]
    shortcuts = json.loads((DESTINATION / "HostResources/AppShortcuts.xcstrings").read_text())["strings"]
    check_native_keys(ROOT, native, shortcuts)
    symbols = re.findall(r"@symbol (\w+)", CATALOG.read_text())
    assert len(symbols) == len(set(symbols)), "Duplicate localization symbols"
    check_plain_key_collisions(json.loads(CATALOG.read_text())["strings"])
    print("Localization source checks passed; compilation and language UI review are separate checks.")


def check_plain_key_collisions(strings):
    names = {}
    for key, entry in strings.items():
        if not key.isascii() or "${" in key or "%" in key or entry.get("shouldGenerateSymbol") is False:
            continue
        words = re.findall(r"[a-z0-9]+", key.lower())
        if not words:
            continue
        name = words[0] + "".join(word.capitalize() for word in words[1:])
        assert name not in names, (key, names.get(name), "Colliding plain keys; namespace metadata keys with intent_")
        names[name] = key


if __name__ == "__main__":
    main()
