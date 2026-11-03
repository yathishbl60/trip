"""Validate host/extension wiring without invoking a build or live system services."""
import plistlib
import re


def check_system_surfaces(root, objects):
    targets = {item.get("name"): item for item in objects.values() if item.get("isa") == "PBXNativeTarget"}
    app, widget = targets.get("trip"), targets.get("TripWidgets")
    if not app or not widget:
        return ["Trip's host or widget extension target is missing"]
    errors = []
    dependencies = [objects[item].get("target") for item in app.get("dependencies", [])]
    widget_id = next(key for key, value in objects.items() if value is widget)
    if widget_id not in dependencies:
        errors.append("The host does not build its widget extension")
    embedded = [objects[item].get("fileRef") for phase in app["buildPhases"]
                if objects[phase]["isa"] == "PBXCopyFilesBuildPhase" for item in objects[phase].get("files", [])]
    if widget["productReference"] not in embedded:
        errors.append("The host does not embed its widget extension")
    source_refs = [objects[item].get("fileRef") for phase in widget["buildPhases"]
                   if objects[phase]["isa"] == "PBXSourcesBuildPhase" for item in objects[phase].get("files", [])]
    shared = {objects[ref].get("path") for ref in source_refs if ref in objects
              and objects[ref].get("path", "").startswith("trip/Shared/System/")}
    expected = {str(path.relative_to(root)) for path in (root / "trip/Shared/System").glob("*.swift")}
    if shared != expected:
        errors.append("The widget's shared system source membership is incomplete or stale")
    errors += check_entitlements(root, app, widget, objects)
    return errors


def check_entitlements(root, app, widget, objects):
    errors, groups = [], []
    for target in (app, widget):
        configurations = objects[target["buildConfigurationList"]]["buildConfigurations"]
        for configuration in configurations:
            settings = objects[configuration]["buildSettings"]
            with (root / settings["CODE_SIGN_ENTITLEMENTS"]).open("rb") as file:
                groups.append(plistlib.load(file).get("com.apple.security.application-groups"))
    system = (root / "trip/Shared/System/TripSystemData.swift").read_text()
    expected = re.search(r'static let appGroup = "([^"]+)"', system).group(1)
    if any(group != [expected] for group in groups):
        errors.append("Host and widget App Groups do not match TripSystemData")
    with (root / "trip/App/Info.plist").open("rb") as file:
        app_info = plistlib.load(file)
    if app_info.get("NSSupportsLiveActivities") is not True:
        errors.append("The host does not declare Live Activity support")
    with (root / "TripWidgets/Info.plist").open("rb") as file:
        widget_info = plistlib.load(file)
    if widget_info.get("NSExtension", {}).get("NSExtensionPointIdentifier") != "com.apple.widgetkit-extension":
        errors.append("The widget extension point is missing")
    return errors
