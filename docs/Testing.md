# Choose and run checks

Use this guide when selecting checks for a change or extending authorized test
coverage. Prepare [Python and Xcode](../CONTRIBUTING.md#local-setup) first. Keep
builds, benchmarks, executable tests, and runtime review within the requested scope.

## Source checks

Run the full source gate on macOS with the selected project Xcode:

```sh
bash scripts/check.sh
# Include committed whitespace changes from the merge base:
bash scripts/check.sh --base origin/main --head HEAD
```

The gate checks ownership, module edges, references, localization, design policy,
source/member limits, preview syntax, UIKit exclusion, and whitespace. It parses
Swift without building the app or running application behavior.

For documentation and contributor-tool work without Xcode, run the portable subset:

```sh
python3 scripts/check_whitespace.py
python3 scripts/workspace.py check
python3 scripts/check_project_skills.py
python3 scripts/check_design_system.py
```

These commands require Python 3.10+ and no third-party packages. They do not replace
the macOS architecture, localization, and SwiftSyntax checks. For Markdown edits,
also follow relative links and verify named files, commands, and anchors.

## Select compilation and behavior checks

| Change | Command | Scope |
| --- | --- | --- |
| Contributor tooling | `python3 -m unittest discover -s scripts -p 'test_*.py'` | Portable Python tests |
| Source-audit tooling | `bash scripts/test.sh tooling` | Python tests and executable SwiftSyntax fixtures |
| One package | `bash scripts/build.sh TripDomain Debug` | Host-Mac compilation; replace the product as needed |
| iOS app | `bash scripts/build.sh app Debug` | Generic iOS Simulator compilation with signing disabled |
| visionOS app | `bash scripts/build.sh visionOS Debug` | Generic visionOS Simulator compilation with signing disabled |
| Hosted model bundle | `bash scripts/build.sh models Debug` | Build for testing; no test execution |
| Public package behavior | `bash scripts/test.sh package` | Package tests on the host Mac |
| App-model behavior | `bash scripts/test.sh models 'platform=iOS Simulator,id=<simulator-UDID>'` | Tests on the explicit simulator |
| Map/domain algorithms | `bash scripts/performance.sh check` | Standalone correctness checks |
| System projections | `bash scripts/performance.sh system-check` | Standalone correctness checks |

Package products are listed in [TripKit](../Packages/TripKit/README.md). Use
`Release` for optimized compilation. Package execution needs a compatible host
macOS, not just a newer SDK. For timings, follow the [performance procedure](../PERFORMANCE.md).

Replace simulator placeholders with an available destination. Alternatively set
`TRIP_TEST_DESTINATION`; no device is selected implicitly. Use a disposable
simulator for unsigned tests, preserving any valued signed App Group installation.
Use an absolute `TRIP_BUILD_ROOT` to isolate app/package output when needed.

Wrap authorized commands with `python3 scripts/verify.py --kind <category> -- ...`
to capture exact command, source digests, toolchain, and exit status. Include
platform/configuration when relevant. Keep source checks, compilation, tests, and
visual review distinct in PR reports. For CI setup, follow [Automation](Development.md#automation).

## Extend hosted model checks

Use [TripModels.xctestplan](../TestPlans/TripModels.xctestplan) and the shared
`TripAppTests` scheme. The plan sets `TRIP_MODEL_TEST_HOST=1`; in Debug, the app
renders an empty host and skips production startup. The flag has no Release effect.
Keep this isolation when editing the host.

Import the app with `@testable import trip`. Construct models with local providers;
do not copy app sources into tests or widen APIs solely for testing. Use the
existing navigation, checklist, packing, library-lifetime, and host-callback suites
as entry points for the corresponding behavior.

Use `ControlledTripStore` for suspended/out-of-order saves and
`NavigationTestStore` for controlled loads. Inject a `TripAIClient` with a controlled
provider, availability closure, and error mapper. Resume canceled or superseded
requests deliberately to check stale-result rejection; `ControlledPackingPlanner`
supports this pattern. Keep each fake's mutable state scoped to its test.

Supply `TripStopOrderSuggesting` to check known proposals, errors, day identity,
tracking restrictions, stop IDs, and preserved notes. Use `PreviewTripServices`
for interactive previews; executable tests own their fixtures and do not import
DEBUG preview types.

## Keep Siri evaluation separate

Follow [Siri evaluations](../Performance/SiriEvaluations/README.md) for the hosted
`TripSiriEvaluations` target. Use `check_siri_evaluations.sh` to type-check scenarios
or `build_siri_evaluations.sh Debug` to build the app, widget, and evaluation bundle
for iPhoneOS without execution. Device evaluation needs an explicit request and
eligible hardware, configuration, and accounts. Do not apply the model-only host
flag to Siri scenarios that exercise system services.

## Place new coverage in its owner

| Responsibility | Placement | Useful seam |
| --- | --- | --- |
| Values, time zones, editing, projections | Existing `TripDomainTests` or standalone checks | Sendable inputs and fixed dates |
| Place conversion/classification | Existing `TripPlacesTests` | Constructed MapKit values and exported adapters |
| Routing | Existing `TripRoutingTests` | `DirectionsProviding` |
| Map layout/ranking/cache | MapEngine package or standalone harness | Fixed coordinates and bounded policies |
| Store migration/revisions | TripStorage package | Isolated container or temporary store |
| AI draft validation | TripIntelligence package | Supplied data and bounded drafts |
| UI models/cross-window edits | Existing `TripAppTests` | Injected store, AI, and stop-order contracts |
| Native maps, navigation, accessibility | Requested UI/device review | Explicit states and stable identities |

Add a test target only when requested and appropriate to the module. Retain Swift
6 isolation and deployment requirements. The standalone harness compiles production
files with `TRIP_STANDALONE`; use package/app compilation for real module boundaries.

Choose cases that exercise the changed contract: failures and retries, edits during
saves, cancellation, late results, deleted identities, legacy decoding, and
preservation of unrelated data. Review Dynamic Type, VoiceOver, Reduce Motion,
long text, and adaptive windows when UI behavior changes. Avoid assertions against
exact live AI wording or tests that simply repeat implementation details.
