# Repeatable performance checks

Run from the repository root on macOS with Xcode 27 / Swift 6.4 and Python 3.
No dependencies, network requests, simulator, signing, or app test target are needed.
If Command Line Tools is selected, point this shell at your full Xcode installation:

```sh
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
bash scripts/performance.sh
bash scripts/audit_sources.sh
```

The default `all` mode compiles the current production files listed in `sources.txt`,
runs correctness checks, then benchmarks. Comparison-tool checks also run in `all`
and `check` modes. It uses Swift 6 complete concurrency,
default MainActor isolation, `-O`, and whole-module optimization. No copied version
of the production algorithms is stored here. All Swift files obey the 100/20 limits.

The source list follows production files in `Packages/TripKit/Sources` and
`trip/Features/Explore`. The runner defines `TRIP_STANDALONE` to compile them
together for internal checks. Normal Xcode and package builds compile the real
module boundaries without that flag. Source moves change report digests; retain
existing baselines as historical measurements rather than rewriting them.

## Contents

- [Commands](#commands)
- [Coverage](#coverage)
- [Extending the suite](#extending-the-suite)

## Commands

```sh
# Algorithm checks only (nonzero exit on failure)
bash scripts/performance.sh check

# Focused saved-data, time-zone, scheduling, journey, and Today checks; no benchmarks
bash scripts/performance.sh system-check

# Timings only, explicitly marked as not correctness-checked
bash scripts/performance.sh benchmark

# Capture a baseline before a change, then rerun after the change
bash scripts/performance.sh all .build/performance/before.json
bash scripts/performance.sh all .build/performance/after.json
python3 scripts/compare_performance.py \
  .build/performance/before.json .build/performance/after.json

# Optional regression gate: fail if median OR p95 is over 20% slower
python3 scripts/compare_performance.py \
  .build/performance/before.json .build/performance/after.json --max-regression 20
```

Reports default to `.build/performance/latest.json`. Each contains per-workload
median/p95 microseconds, warm-up/sample counts, output-count checksums, source hash,
Git revision and dirty flag, timestamp, CPU, macOS, architecture, SDK, and compiler.
Build products, module caches, and raw reports stay in ignored `.build/performance`.
Keep the source unchanged during a run and avoid concurrent benchmark runs.

Saved-data coverage includes Siri visit timing edits: preserving omitted fields
and notes, repeat-call idempotency, next-day/flexible arrivals, invalid bounds,
booking/deleted targets, and missing/repeated daylight-saving clocks. Shared saved
details retain their source day and exclude private notes. These deterministic
checks do not execute Siri, Maps handoff, or the native share sheet.

`system-check` runs projection/privacy, saved-action identity, exact-date briefing,
legacy migration, civil-clock/DST/date-line, scheduling, journey mutation, and
Today regression checks. It compiles the same production source manifest with
strict concurrency, runs no timing workloads, and writes no benchmark report.

`TripPackingChecks` adds checklist deduplication/capacity, exact cross-trip identities,
private checklist-text exclusion, count-only widget publication, bounded packing
context, and legacy snapshot checks. It does not evaluate model output or Siri UI.

`TripNextStepChecks` covers tracking progress, exact-day selection, cross-trip and
expired-session isolation, stable upcoming priority, start/end timeline boundaries,
and time-review preservation. The checks are registered in `system-check`; adding
them does not establish that they have been run.

`TripSurfaceSelectionChecks` defines active overnight tracking, ended-session day
rollover, completed visits with a later flight, expiry, and deleted/foreign target
coverage. It exercises the widget's production day/session selector, not WidgetKit
rendering, timeline delivery, or button execution. Run the focused harness to verify the current revision.

`PlaceSearchChecks` defines cross-field Unicode/whitespace matching, stable name
relevance, matching before result limits, duplicate-listing/branch preservation and
combined detail day/category/text filtering. It is registered in `system-check`;
these checks do not verify live search or UI interactions.

The source audit lives in `scripts/audit_sources.swift` and
`scripts/SourceAudit/MemberAudit.swift`, with a shell runner using Xcode’s
bundled SwiftSyntax parser. It checks physical file/member line limits,
same-file previews, and project skill lengths, including its own Swift source.
Its generated module cache stays in ignored `.build/audit`. These runners have no
dependency on `/tmp` or files outside the repository other than the installed SDK.

The zoom review's paired reports are retained as
`Baselines/zoom-review-before-mac.json` and `Baselines/zoom-review-after-mac.json`.
They have matching workloads/environments and preserve their original source digests.

Comparison rejects mismatched workloads, sample counts, checksums, or environments.
`--allow-environment-mismatch` explicitly allows a hardware/toolchain comparison,
with a warning. A source change is expected; a workload/checksum change needs a new
baseline. Timing failures are opt-in because unrelated machine load adds noise.
Use repeated runs on an idle, similarly powered/thermally stable machine.

`Baselines/development-mac.json` includes the source digest and machine metadata
needed to interpret its measurements. Prefer your own local baseline; the
comparison command requires an explicit override when the recorded machine differs.

## Coverage

The standalone correctness suite exercises asymmetric book and tabletop folds,
mirrored coordinates, clipping, invalid measurements, and narrow strips on either
side of the day map. Native hinge callbacks and rendered poses require a Duo
runtime. [Trip's adaptive layout contract](../UNIVERSAL-APP.md)

The 2026-11-05 MapEngine pass adds `LayoutVisualBoundsChecks`,
`LayoutObstructionChecks`, `MapOcclusionChecks`, and `PlaceCollectionChecks` to
the existing `check`/`all` entry points. They cover every edge at -0.25/0/+0.25-point
overlap across all three stages and both supported scale endpoints, malformed
obstructions, finite full-cover/owner reservations, floating sheets and notices,
phantom empty-sheet clearance, and nearest same-name branch identity. Projection
readiness also checks immediate stale-work cancellation before coalesced refresh.
The updated suite passed on 2026-11-06. All 11 benchmark workloads matched their
baseline checksums and passed the 20% regression threshold.
[MapEngine review and paired measurements](../docs/MapEngineReview.md)

Map checks include `CameraGroundScaleChecks`,
`LayoutVisibilityChecks`, and `MarkerRetirementChecks` through the standard check
entry points. They cover calibrated menu stages and dot selection after newer
camera feedback, pitch/viewport fallback, offscreen candidate budgets, edge
overlap, gesture-time style ceilings, and retirement before native appearance.
The bounded-retirement fixture marks annotations as appeared to exercise fade
lifetimes. Algorithm checks do not measure native rendering or device frame pacing.

- Subpixel pan and gentle pinch activity with accumulated projection thresholds;
  bounded geographic ranking against a full-sort oracle, score ties, duplicate
  improvements/reentry, selected places, and invalid camera centers.
- Search cache coverage reuse, original freshness, query/category/zoom boundaries,
  bounded LRU retention, disabled caching, and separate failure/retry history.
- Mixed journey events/visits, stable multi-day spans, legacy event/order defaults,
  save/reload and duplication, mixed reorder and stale-order rejection, span-safe
  day moves/removal, optional/overnight time validation, and AI replacement protection.
- Timed itinerary order and identity, travel/buffer allowances, fixed-arrival waiting
  and conflicts, overnight targets, empty/disabled days, legacy JSON, normalized
  bounds, and daylight-saving clock changes. These are correctness checks, not a
  routing-latency or itinerary UI benchmark.
- Bounded initial projection retries, suspension cancellation, and coalesced sheet geometry.
- Search-area coverage across jitter, pans, zoom changes, queries, categories, and the antimeridian.
- Native annotation reentry preserves visibility; coincident and obscured places remain selectable.
- Spatial hash versus naive intersections, negative coordinates, owner exclusion.
- Indexed lookup versus full scans: 10,000 places, 300 viewports, categories,
  ±180° wrapping, empty/world/invalid bounds, and high-pitch fallback.
- 300 evolving dense layouts across the three levels: unique IDs, collision footprints,
  marker limits, selection beyond the candidate cutoff, and stable movement.
- Duplicate/nonfinite inputs, invalid scale/viewport, deterministic output,
  task cancellation, and retiring/own transition reservations.
- Name deduplication, identity-only providers, collection caps, retained selection,
  malformed policies, search-region identity, and zoom hysteresis.
- Latest queued layout wins; cancellation followed by restart cannot publish old work.
- Camera feedback retains its latest position without invalidating map content;
  focus and zoom commands still notify observers.
- Final-size fade entry, Reduce Motion, uninterrupted size changes, retirement, and revival after hiding.
- Photo/label content is deferred for small markers and retained after promotion.
- Orientation actions become available after rotation/tilt and reset on camera return.
- Centered footprints, unchanged selection bounds, and rapid transition reversals at every style.
- Projection invalidation notifies the map, cancels queued layout/refinement, and
  allows a fresh layout; suspension prevents delayed publication.
- Starting another gesture cancels the previous settled layout without an extra
  map observation update. Both zoom boundaries resist repeated pinch jitter
  at minimum, default, and maximum configured hysteresis.
- Fast zoom jumps, invalid ground scale, heading/dateline wrapping, and camera
  perspective/history preservation through every programmatic zoom level.
- Candidate limits preserve the full ranking's prefix, remove duplicate IDs,
  and keep selection first without collecting unused ranked candidates.
- Eighty rapid replacements retain all 110 active markers with at most 22 retirees;
  Reduce Motion removes retired markers immediately.
- Camera return restores position, distance, heading, and pitch; no-op commands
  retain history. Small pans accumulate without suppressing zoom or rotation.
- Equal-priority newcomers do not displace existing dots.
- Invisible card-to-dot revival starts at dot size, clears stale artwork, and
  rejects lifecycle callbacks from the prior presentation, including native-view reentry.
- Zoom-boundary promotions wait for settlement; new markers enter as dots during
  movement. Custom ladders downgrade safely, and crowded cards fall back to compact
  icons/images, then dots. The engine exposes exactly three appearances and levels.
- Shrinking markers keep normal clearance; fading transitions retain
  their occupied bounds, including when Reduce Motion interrupts an animation.
- Selected places retain their zoom appearance by default; hosts can opt into
  readable labels. Labels fall back at viewport edges or obstructing
  neighbors without bypassing collision checks.

`Baselines/annotation-redesign-mac.json` records the horizontal annotation design.
Its output counts differ from earlier vertical treatments because the collision
footprints changed. Treat it as a fresh baseline, not a before/after speed claim.
For repeatable component images, run `bash scripts/annotation-preview.sh`; outputs
and caches stay in `.build/annotation-preview`. This renderer uses the app's actual
SwiftUI views and assets, but does not exercise MapKit or animation frame pacing.

The lookup benchmark uses 2,000/50,000 places over 0.4°/6° extents, 100 five-kilometer
viewports, 200 warm-ups and 1,000 measured queries per metric. It excludes index
construction. The layout benchmark uses 2,000 points, a 1600 × 1200 viewport, 1.5×
scale, and 20 warm-ups plus 200 measured layouts per zoom mode. History carries
between frames. Checksums make reduced output visible during comparisons.

## Extending the suite

Add checks beside the relevant check file and call them from `PerformanceRunner`.
Keep timed input setup outside the measured interval. Add imported production files
to `sources.txt`. Change `workloadVersion` when fixtures, measurement boundaries,
iterations, or metric semantics change; create a new baseline afterward.

These checks measure host CPU algorithms. They do not measure iOS frame pacing,
MapKit projection/rendering, GPU, memory pressure, search latency, or visual quality.
Use the device profiling steps in `../PERFORMANCE.md` for those measurements.

Reviewed itinerary checks cover stable identities, preserved notes, stale edits,
scheduled visits, missing places and intentional repeat visits. They run in check mode.

`TripSystemActionChecks` also covers source-backed answer privacy, a stay spanning
multiple days, unsupported questions, missing days, and refreshing after deletion.
Run these with the existing `system-check` command when verification is requested.

`TripSystemProjectionChecks` covers mixed journey ordering, private-note exclusion,
legacy App Group projections, event time boundaries, deduplicated spanning stays,
unsupported detail queries, and exact-date Siri briefings. These are deterministic
domain checks; they do not exercise Foundation Models, WidgetKit scheduling, Siri
metadata export, or signed-device Live Activities.

Day-planning checks are included in `check` and `system-check` through
`TripScheduleChecks`: fixed-arrival crossing, atomic rejected moves, mixed booking
slots, duplicate/capacity admission, empty days, booking/transfer overlaps,
touching endpoints, untimed days, unreviewed zones and hotel check-in/out semantics.
Insertion checks additionally cover nearest gaps, date-line neighbors, invalid
coordinates, distant places and empty-day ranking.
`TripPlanningChecks` and `TripBookingConflictChecks` exercise production domain
code. These additions have source-audit coverage; they have not yet been executed.

`TripStopTransferChecks` and `TripStopTransferValidationChecks` run through
`TripJourneyChecks`. They cover atomic cross-day and same-day drops, empty days,
mixed booking gaps, identity/notes/timing retention, multi-source ordering,
fixed-arrival boundaries, duplicate/full destinations, stale edits, and missing
drop targets. They use the production `TripStopTransfer` sources. They have
source-audit coverage; execution requires a requested algorithm-check run.

`TripBookingImportChecks` covers conservative document proposals, AM/PM and midnight,
preserved offset evidence, ambiguous and invalid dates, and bounded text/date choices.
It is registered in `system-check` and uses production parser sources. These new
checks have source-audit coverage; they have not yet been executed.
