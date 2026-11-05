"""Check declared package edges and compiler policy without executing a manifest."""
import re


def check_package_manifest(source, graph):
    errors = []
    declarations = re.findall(r'\bmodule\("(\w+)"(?:,\s*dependencies:\s*\[([^\]]*)\])?\)', source)
    actual = {name: re.findall(r'"(\w+)"', dependencies) for name, dependencies in declarations}
    if len(declarations) != len(actual) or actual != graph:
        errors.append("Package.swift module declarations disagree with modules.json")
    libraries = re.findall(r'\.library\(name:\s*"(\w+)",\s*targets:\s*\["(\w+)"\]\)', source)
    if len(libraries) != len(graph) or dict(libraries) != {name: name for name in graph}:
        errors.append("Package.swift library products disagree with modules.json")
    required = ['swiftLanguageModes: [.v6]', '.defaultIsolation(MainActor.self)',
                '.enableUpcomingFeature("MemberImportVisibility")',
                '.iOS("27.3")', '.macOS("27.3")', '.visionOS("27.3")']
    for setting in required:
        if setting not in source:
            errors.append(f"Package compiler/platform contract missing: {setting}")
    return errors


def check_compiler_settings(objects):
    errors = []
    project = next(item for item in objects.values() if item.get("isa") == "PBXProject")
    inherited = configurations(project, objects)
    required = {"SWIFT_VERSION": "6.0", "SWIFT_STRICT_CONCURRENCY": "complete",
                "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
                "SWIFT_APPROACHABLE_CONCURRENCY": "YES", "SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY": "YES",
                "IPHONEOS_DEPLOYMENT_TARGET": "27.3", "XROS_DEPLOYMENT_TARGET": "27.3"}
    for target in objects.values():
        if target.get("isa") != "PBXNativeTarget":
            continue
        for name, overrides in configurations(target, objects).items():
            settings = inherited.get(name, {}) | overrides
            for key, value in required.items():
                if settings.get(key) != value:
                    errors.append(f"{target['name']} {name}: expected {key}={value}")
    return errors


def configurations(owner, objects):
    identifiers = objects[owner["buildConfigurationList"]]["buildConfigurations"]
    return {objects[item]["name"]: objects[item]["buildSettings"] for item in identifiers}
