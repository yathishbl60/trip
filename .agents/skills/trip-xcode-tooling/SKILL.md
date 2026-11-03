---
name: trip-xcode-tooling
description: Apply Trip's target wiring, output locations, and verification constraints during requested profiling, device checks, or Xcode configuration changes.
---

# Trip Xcode integration contracts

Read [rules](../../../AGENTS.md), [scripts](../../../scripts/README.md), and the affected owner's context.
Profiling and specialized tooling methods belong to global `app-development` quality topics.
Load only the requested workflow; private historical archives are optional reference material.

## Trip configuration boundaries

- Use the shared trip scheme and project scripts; app compilation includes TripWidgets.
- Host and extension share designated Shared/System sources, localization, and DesignSystem assets.
- Preserve App Groups, bundle identifiers, embedding, deployment, and platform guards.
- Keep Swift 6 concurrency and MemberImportVisibility enabled.
- Scripts honor DEVELOPER_DIR and keep generated output in ignored .build.
- Performance checks and baselines belong in Performance and scripts; read [performance ownership](../../../Performance/README.md).
- Profile Explore's native camera/projection and MapEngine workers separately before attributing map cost.
- Keep local preview services isolated from live storage and device sessions.
- C-safety or document recipes apply only to an actual requested C/document workflow.
- Trip's SwiftData persistence and current target/security policy are not replaced by importing a recipe.

## Verification scope

Use [trip-previews-build](../trip-previews-build/SKILL.md) for commands and preview constraints.
Builds/benchmarks run only when requested; do not add unrelated app test targets.
Signed-device checks are needed for supported Siri, widgets, and Live Activities.
Preserve device data and settings; report actual source/build/runtime/performance evidence separately.
