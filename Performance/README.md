# Production algorithm harness

Use this harness when changing spatial lookup, map layout/lifecycle, saved-trip
rules, system projections, or related CPU algorithms. It compiles the production
sources listed in `sources.txt` together with deterministic checks and benchmarks.
It does not launch Trip, call live services, or measure MapKit rendering.

## Prerequisites and boundaries

Use macOS with the project's Xcode/SDK baseline and Python 3.10+. Select an explicit
`DEVELOPER_DIR` when the system-selected Xcode is unsuitable; scripts never change
global `xcode-select`. Follow [contributor setup](../CONTRIBUTING.md) and use
`python3 scripts/workspace.py doctor --json` to inspect the environment.

The runner uses `TRIP_STANDALONE`, Swift 6 strict concurrency, default MainActor
isolation, `-O`, and whole-module optimization. Package/app builds separately check
real module boundaries. Keep all authored Swift within the project file/member
limits. No simulator, app test target, signing, or remote dependency is required.

## Commands

Run from the repository root within the requested verification scope:

```sh
# Production correctness checks; no timing workloads.
bash scripts/performance.sh check

# Saved-data, projections, civil time, scheduling, journey, and Today checks.
bash scripts/performance.sh system-check

# Timing workloads only; the report does not claim correctness was checked.
bash scripts/performance.sh benchmark

# Correctness plus timings, using distinct before/after files.
bash scripts/performance.sh all .build/performance/before.json
bash scripts/performance.sh all .build/performance/after.json
python3 scripts/compare_performance.py .build/performance/before.json .build/performance/after.json

# Optional gate on either median or p95 regression.
python3 scripts/compare_performance.py .build/performance/before.json .build/performance/after.json --max-regression 20
```

Calling `performance.sh` without a mode runs `all`, including benchmarks. Choose
`check` or `system-check` explicitly when only correctness is intended. `check` and
`all` also run the Python comparison-tool checks. `system-check` writes no benchmark
report. Timing reports default to `.build/performance/latest.json`; use named paths
to preserve a comparison pair.

Build products, caches, localization resources, and raw reports stay in
`.build/performance`. Each invocation uses its own run directory. Keep source fixed
while measuring and avoid concurrent benchmarks or unrelated heavy workloads.

## Coverage and entry points

`PerformanceRunner.swift` registers the top-level checks and benchmarks. Follow the
called check groups to locate the actual assertions before changing coverage.

| Area | Representative owners/check groups |
| --- | --- |
| Spatial lookup | SpatialChecks, IndexChecks, geographic benchmarks |
| Place search and cache | DataChecks, PlaceSearchChecks, PlaceCollectionChecks, SearchCacheChecks, SearchCoverageChecks |
| Map layout and identity | LayoutChecks, LayoutVisualBoundsChecks, LayoutObstructionChecks, AnnotationChoiceChecks |
| Camera, projection, and lifecycle | CameraFeedbackChecks, CameraNavigationChecks, CameraRestorationChecks, GeographicCoverageChecks, ProjectionLifecycleChecks, MarkerTransitionChecks, SchedulerChecks |
| Adaptive map geometry | TripPaneDivisionChecks, MapOcclusionChecks |
| Schedules and insertion | TripScheduleChecks, TripPlanningChecks, TripBookingConflictChecks |
| Journey edits and movement | TripJourneyChecks, TripStopTransferChecks, TripVisitTimingChecks |
| System projections and lookup | TripSystemProjectionChecks, TripSystemActionChecks, TripNextStepChecks, TripSurfaceSelectionChecks |
| Civil time and Today | TripTimeZoneChecks, TripZonedScheduleChecks, TripTodayChecks |
| Preparation and import | TripPackingChecks, TripBookingImportChecks |

Map cases exercise bounded candidate ranking, collisions and obstructions, stable
identities, visibility/retirement, three annotation stages, zoom hysteresis, invalid
geometry, cancellation, and latest-result publication. Use oracle comparisons and
output checksums to detect less work disguised as an optimization.

Saved-data cases exercise mixed visits/bookings, spanning stays, identity/notes
retention, atomic rejected edits, duplicate/capacity limits, legacy decoding, privacy,
exact-day selection, tracking expiry, local-clock/DST rules, and parser bounds.
These checks do not execute Siri, native permission sheets, external app exports,
WidgetKit delivery, AI generation, or live MapKit search.

The `system-check` entry calls `TripSystemProjectionChecks.run()`, which registers
its saved-data groups, including schedules, journeys, preparation, search, and import.
The broader `check` entry also includes those groups. Read registration code before
assuming that a similarly named file runs in a particular mode.

## Compare reports

Reports include workload/schema versions, median/p95 microseconds, warm-up and sample
counts, output checksums, source digest, revision/dirty state, timestamp, architecture,
CPU, macOS, SDK, compiler, and flags. Preserve that metadata with any shared result.
A changed source digest is expected after an implementation change; changed workloads
or output checksums require explanation and usually a new baseline.

The comparison command rejects incompatible workloads, metric sets, sample counts,
checksums, and environments. `--allow-environment-mismatch` permits an explicit
hardware/toolchain comparison with a warning; it does not isolate code performance.
Timing regression failure is opt-in through `--max-regression`. Use repeated runs on
an idle machine with comparable thermal/power conditions.

Checked-in files in `Baselines/` are fixed reference inputs. Read their metadata
before choosing one; do not rewrite them to match new source hashes or compare
different workload versions. Prefer a local before/after pair for the current task.
The annotation-redesign report uses different output counts from older treatments;
those reports cannot establish a controlled speed comparison.

Geographic timing excludes index construction. Layout timing carries history between
frames. Inspect `GeographicBenchmarks` and `LayoutBenchmarks` for current dataset sizes,
measurement boundaries, and iteration counts before changing a workload.

## Extend the harness

1. Identify the production contract and owning check group. Reuse deterministic
   fixtures and assert behavior at a meaningful boundary.
2. Add required production files to `sources.txt`; never copy implementations into
   the harness. Keep generated localization entries under the existing generator.
3. Register the check in the appropriate group/entry point. Preserve cancellation
   and strict concurrency requirements.
4. Keep timed input construction outside measured intervals. Change `workloadVersion`
   when fixtures, iterations, boundaries, or metric meaning changes.
5. Run authorized correctness checks before interpreting a performance difference.
   Establish a fresh baseline when the comparison contract changes.

Source enforcement belongs to `scripts/audit_sources.sh` and its SwiftSyntax sources;
Siri evaluation procedures belong to [SiriEvaluations](SiriEvaluations/README.md).
For actual SwiftUI component images, `scripts/annotation-preview.sh` uses production
views/assets when visual work is requested. It still does not exercise native MapKit
interaction or animation frame pacing. Use [device profiling](../PERFORMANCE.md)
for launch, gestures, GPU, memory pressure, network, and native responsiveness.
