---
name: trip-previews-build
description: Configure Trip's local preview fixtures, enforce source limits, or run requested app/package builds and report verification scope.
---

# Trip previews and verification

Read [rules](../../../AGENTS.md) and [preview ownership](../../../docs/PreviewSupport.md).
General preview design and verification practice live in global `app-development` previews/verification topics.

## Preview contracts

- Every view, including private views, has a named same-file #Preview.
- Keep the entire Swift file within 100 lines and each member within 20 lines.
- Use PreviewFixtures and PreviewTripServices; guard DEBUG-only fixtures.
- Component previews use local services; intentional live-service previews must be labeled.
- Keep the interactive appearance picker in PlaceMarkerView and cover all three marker treatments.
- Render changed saved-place action rows in their List host with all enabled host callbacks.
- Include the relevant empty/loading/failure, long-content, dark, and large-text variants.

## Commands and evidence

`bash scripts/check.sh` audits ownership, previews, limits, localization, and prohibited UIKit use.
`python3 scripts/check_architecture.py` is required after moving sources or changing dependencies.
Source checks verify named preview syntax, not rendered coverage, and do not type-check Swift.
Use `scripts/verify.py` for revision/source-digest evidence; see [testing](../../../docs/Testing.md).
Read [compiler boundaries](references/compiler-boundaries.md) before changing shared helpers or queries.

Builds and benchmarks run only when requested; a reported build failure requests repair and compilation.
Use `bash scripts/build.sh app Debug` for the generic iOS Simulator configuration.
The app build includes widgets; inspect both targets and AppIntentsMetadataProcessing.
Use named package targets from [TripKit](../../../Packages/TripKit/README.md) for requested package builds.
Keep independent iOS/visionOS verification scope from [universal support](../../../UNIVERSAL-APP.md).
Keep output in ignored .build; build/test scripts accept absolute TRIP_BUILD_ROOT for isolated worktrees.
Scripts honor DEVELOPER_DIR without changing global Xcode selection.
Requested model checks use TripAppTests/TripModels with an explicit Simulator destination.
For requested algorithms use `bash scripts/performance.sh check` or `system-check`; see [Performance](../../../Performance/README.md).
Use [trip-xcode-tooling](../trip-xcode-tooling/SKILL.md) for target wiring and profiling ownership.

## Product acceptance

Read [runtime flows](references/runtime-flows.md) for affected screens and adjacent workflows.
Report actual configurations, completed checks, and gaps separately; earlier builds do not verify later edits.
