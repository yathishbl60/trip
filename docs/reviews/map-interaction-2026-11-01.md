# Map interaction refinement · November 1, 2026

## User value and acceptance

Map browsing should retain useful places through pans and zooms, make selected
dots readable, and avoid visual gaps caused by obsolete annotation work. The
existing Explore map, filters, native annotations, and place sheet remain the
entry points. This work preserves the dot / icon or photo / labeled progression,
stable place identities, selection, native gestures, and camera perspective.

Acceptance focuses on viewport-edge candidates, gesture-time representation
limits, markers removed before appearing, rapid zoom changes, and Reduce Motion.
Existing local dense-map and accessibility previews remain the visual fixtures.

## Ownership and contracts

Explore owns live MapProxy projection, camera state, and marker presentation.
MapEngine owns reusable zoom, ranking, and placement policy. The work follows
`workspace.py context Explore --json`, `workspace.py context MapEngine --json`,
the Trip map contract, and the global app-development maps and motion topics.
No persistence schema, service, package dependency, or navigation changes were
made. Background layouts remain bounded, cancellable, and generation checked.

## Delivered changes

- `ZoomLevel` owns both transition boundaries and preferred ground scales.
  Camera commands use a paired ground-scale/distance snapshot when viewport and
  pitch match; existing distance presets remain the fallback. The calibration
  never combines an older scale with newer camera feedback. Empty catalogs no
  longer prevent zoom state from updating.
- Ranking rejects candidates whose allowed footprints cannot intersect the
  viewport before applying the layout candidate limit. Ranking and placement
  share the same eligibility rule, including gesture ceilings and selected-label
  containment. Partly visible edge annotations remain eligible.
- A marker removed before native appearance reserves no phantom fade space and
  is pruned immediately. Visible annotations retain fading reservations and the
  retiree budget. Existing rendering and native gesture ownership are unchanged.

The geographic candidate cap still precedes native projection; this change does
not promise exhaustive visible-area coverage at extreme density/pitch. Calibrated
camera distance is an estimate and is clamped to the supported navigation range.
Native projection determines the actual settled annotation stage.

## Readability follow-up

The review identified unexplained tuning values, repeated rules, positional
arguments, and dense arithmetic. The follow-up keeps behavior and defaults while
making the decisions readable:

- Zoom resolution now names each starting stage and direction instead of indexing
  an array using enum raw values. Icon/label thresholds have units, and layout
  configuration reuses the same hysteresis defaults.
- Camera navigation and projection policies own their limits and tolerances.
  Calibration names the measured distance and estimated zoom ratio. Unused
  bootstrap camera/region values were removed from initialization.
- Movement detection names pan, rotation, pitch, and zoom conditions separately.
  Camera transition timing names travel, zoom doublings, and orientation changes.
- Placement uses labeled arguments and shares documented clearance, density,
  and continuity rules with rendering. No duplicate 4/9-point spacing remains
  across the placement, selection, and retirement paths.
- Marker reservation guards are flattened; active reservations have a single
  predicate. Motion allowances and bounded projection retry delays have names
  and lifecycle explanations.

The Explore guide includes a tuning-owner table. These are responsibility-specific
policies, not a general constants registry. Existing regression cases are retained;
this pass adds no unrelated test target or behavior experiment.

The placement-policy extension is explicitly `nonisolated`: its pure density,
clearance, and priority calculations run in the layout actor. Without that
declaration, the package's default MainActor isolation caused compilation errors.
The fix preserves complete concurrency checks and deployment requirements.

## Verification

The initial and final `bash scripts/check.sh` pass: architecture and manifest
validation, workspace references, project skills, localization, Swift source
limits, required previews, and whitespace. The initial improvement audit covered
829 Swift files; the readability follow-up is also covered by the source gate.
The installed Xcode 27.2 / macOS SDK 27.2
MapKit-SwiftUI declarations were inspected for MapCamera; no platform minimum or
availability guards changed.

New checks in the existing Performance harness cover calibration after advancing
feedback, target stages across hysteresis settings, geometry fallback, invalid
measurements, viewport eligibility, preappearance retirement, and visible fades.
They are registered and source-audited, but not executed. The requested Debug
build now succeeds for the single iPhone 18 Pro Max simulator, iOS 27.2, arm64,
using the shared `trip` scheme and `.build/xcode` output. App, TripWidgets, and
App Intents metadata extraction complete; the final log contains no compiler
warning/error diagnostics. The build log is `.build/build-errors-fix.log`.
`bash scripts/check.sh` also passes after the isolation fix.

No other simulator/platform build or algorithm benchmark was run for the repair.
Native gesture/animation quality, frame pacing, large-text rendering, VoiceOver,
and device Reduce Motion behavior remain unverified. No measured speed or
frame-rate claim is made.
