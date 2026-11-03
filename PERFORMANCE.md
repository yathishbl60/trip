# Performance and validation

The runnable suite is checked in under [Performance](Performance/README.md).
Run `bash scripts/performance.sh` for correctness checks and JSON benchmark results.

## Map responsiveness source review — 2026-10-14

Camera activity now detects every changed sample, independently of the accumulated
24-point pan and zoom thresholds used to decide when projection is necessary.
This closes the path where a continuous sequence of subpixel pans or gentle pinch
steps could leave settled refinement active until the gesture ended. Feedback
still writes ignored state; it does not invalidate the annotation tree per frame.

Geographic candidate ranking now streams the index's matching coordinate slices
through a unique-ID heap bounded by the projection budget. It orders only the
retained candidates, preserving selected-first ranking, continuity, score order,
and ID tie-breaking. For n candidates and budget k, ranking retains O(k) entries
and uses O(n log k + k log k) comparisons rather than sorting all n candidates.
The full geographic index remains cached; this is not a claim about total app memory.

Map searches retain in-flight work through brief gestures, cancel obsolete queued
debounce work, and supersede requests on changed settled input. Successful search
history and a two-second failure cooldown are separate. Coverage-aware cache hits
keep the provider's original timestamp/area and update a bounded LRU, preventing
freshness extension, accumulated coverage drift, and unrelated eviction on replacement.

Added standalone fixtures for slow camera activity, full-sort ranking equivalence,
duplicates and selection, cache retention/expiry, and failure recovery. They are
registered in the existing harness; no app target or dependency was added.
Source/architecture audits passed. Builds, correctness execution, benchmarks, and
native visual verification were not requested and have not run for this change.
No frame-rate or measured latency improvement is claimed. Dense offscreen clusters
in rotated/high-pitch views can still consume projection slots before live conversion.

## Map and routing source review — 2026-10-10

Geographic candidates now retain an immutable `CLLocation` beside their cached map
point. Ranking creates one location for the camera center per query and reuses the
candidate locations. This preserves the existing distance calculation and ranking
while removing two location allocations per candidate from gesture-time queries.

Route construction reserves the combined polyline buffer once and appends native
leg points directly. Route identity feeds explicit little-endian coordinate values
into SHA-256 in bounded chunks, avoiding a temporary array for each vertex and a
second complete byte buffer. Label coordinates are extracted once per route.
Opening directions and explicit retries start immediately; rapidly changing mode,
date, and avoidance preferences retain a 250 ms debounce and stale-result guards.

These are source-supported reductions in allocation and request delay. They do
not establish a frame-rate, memory, or latency improvement on a device. The user
limited this pass to source checks and platform builds; no simulator interaction,
new benchmark result, or Instruments trace was collected.

## What changed

- Cache sorted longitude and latitude indexes when the collection changes.
  Viewport queries binary-search both axes and scan the smaller coordinate band.
  Longitude wraps at ±180°. High-pitch projection uses the conservative full set.
- Merge, deduplicate, count, and index provider results on the repository actor.
- Coalesce layout work into one active job and one replaceable pending request.
  Publish only the newest generation; cancelled work never becomes layout history.
- Ignore duplicate camera callbacks and accumulate 24 points of pan before layout.
  Native annotations still follow MapKit's camera continuously.
- Observe selection per marker, so selecting one does not invalidate every marker.
- Share animation, retirement, and collision-reservation timing; preserve marker
  identities and defer same-level promotion until camera movement settles.
- Permit native map gestures behind the medium detail sheet; adapt detail actions
  to larger text. No footer, toolbar, or marker treatment was removed.

## Measurements

Measured on the development Mac using optimized Swift 6.4 builds on 2026-09-19.
These are CPU microbenchmarks, excluding MapKit rendering, GPU work, and frame rate.
Timing varies by device and run. The original measurements below used temporary
harnesses. The checked-in suite now uses strict Swift 6 and whole-module optimization;
establish a fresh baseline with it instead of directly comparing against this table.
Performance checks are now included at the user's request, outside the app target.

Geographic lookup: 100 five-kilometer viewports, two warm-up passes, ten measured
passes over synthetic catalogs. Index construction is excluded because it runs
once per catalog update on the repository actor. Results matched full scans.

| Catalog / distribution | Full-scan median | Indexed median | Indexed p95 |
| --- | ---: | ---: | ---: |
| 2,000 / 0.4° extent | 9.13 µs | 7.88 µs | 8.29 µs |
| 50,000 / 0.4° extent | 169.33 µs | 120.21 µs | 129.17 µs |
| 50,000 / 6° extent | 148.08 µs | 7.21 µs | 7.63 µs |

Collision layout: 2,000 projected candidates, 1600 × 1200 viewport, 1.5× marker
scale, 20 warm-ups and 200 measured frames per zoom level. Compared with `7058419`,
median layout times improved approximately 1–6% across the five levels. Street
layout median changed from 1.103 ms to 1.039 ms with the same visible count (96).
The geographic lookup improvement must not be interpreted as an app-wide speedup.

## Algorithm checks performed

- 3,000 spatial-hash queries compared with naive rectangle intersections.
- 500 evolving dense layouts across all five levels: bounded counts, unique IDs,
  nonoverlapping computed footprints, and no same-level promotion while moving.
- Selected candidates beyond the normal cutoff, duplicate IDs, cancellation,
  nonfinite points, invalid scale, and zero-sized viewports.
- 300 indexed queries over 10,000 places matched full scans, including category
  filtering, antimeridian endpoints/wrapping, world bounds, null and invalid bounds.
- Rapid submissions delivered only the newest generation; cancelled work delivered none.
- Invalid policy values clamp safely; identity-only merging keeps same-name records distinct.

These checks exercise the placement/data algorithm, not native MapKit's renderer.
Placement remains a bounded greedy heuristic, with conservative transition
reservations. Apple does not expose road-label footprints to this collision layer.

## Device verification

### Explore startup and contextual controls — 2026-09-28

The navigation bar is transparent and the map extends behind it. Search and one
map-options menu are always available while browsing. Back appears only when
camera history exists; orientation reset appears only after tilt or rotation.
Category selection is omitted for a single-category provider. Editing search or
opening a place hides unrelated map controls. Notices overlay the map instead of
resizing it, and successful searches clear their status. Layout excludes the
measured toolbar/tab areas and any visible notice without intercepting gestures.

Startup searches now wait until the initial catalog attempt completes. Activation
revisions reject initial loads after suspension/replacement; empty first-camera
callbacks skip projection, and initial loading invalidates layout only once.
Seed decoding, catalog merging/indexing, and SwiftData initialization already run
on their respective actors. No synchronous main-actor disk access was identified
in the production Explore launch path during this source review.

Dot and badge markers defer photo/caption subtrees until their first promotion.
Once mounted, that content stays mounted through reverse zoom transitions. All
five representations, geographic identities, and marker limits are preserved.
The standalone checks now cover deferred content retention and contextual camera
controls; these additions have not been executed as part of this change.

For a requested device launch capture, inspect `Load initial places`,
`Publish initial places`, `Map projection`, and `Apply map markers` in Points of
Interest (`com.trip.map`). The first interval includes time awaiting actors and
is not a measurement of main-thread occupancy. Compare it with the main-thread
call tree, native MapKit initialization, image decoding, and the first annotation
commit. Keep trace output in `.build/performance` within this repository.

Source/architecture audits do not verify launch latency or frame pacing. No new
build, benchmark, device profile, or visual verification has been run for this
pass. Remaining startup stalls need a device trace before assigning a root cause.
Apple's [responsiveness guidance](https://developer.apple.com/documentation/xcode/improving-app-responsiveness)
describes how to distinguish main-thread work from time spent awaiting results.

### Annotation redesign — 2026-09-23

The five zoom treatments now share a horizontal composition: dot, category badge,
photo token, named rating chip, and category/photo card. A solid adaptive surface
and one shadow replace the overlapping artwork treatments. The stable hierarchy,
centered geographic anchor, native annotation hit testing, and Reduce Motion
behavior remain. Selected artwork and collision bounds use the same scale.

Selection can promote a distant marker into a label, configured through
`MarkerLayoutPolicy.selectionStyle`. The engine still observes transition
reservations, movement stability, and collisions. Checks cover disabling/changing
this promotion, all four viewport edges at 150% size, and neighboring reservations.

The complete standalone suite, all seven comparison-tool checks, source-size and
same-file preview audit, and Debug generic iOS Simulator build passed. The build
used Xcode 27 beta / Swift 6.4 with signing disabled; its only warning was the
expected App Intents extraction skip.

The final optimized host benchmark measured layout medians of 2.291–2.476 ms and
p95 values of 2.398–2.581 ms across the five zoom modes. The raw report is
[`annotation-redesign-mac.json`](Performance/Baselines/annotation-redesign-mac.json).
This is a new baseline: redesigned collision footprints change output counts,
so earlier annotation baselines do not support a direct speedup comparison.

`bash scripts/annotation-preview.sh` renders the production annotation components
and bundled assets into `.build/annotation-preview`. Both light and dark galleries
were inspected for clipping, selection, long names, missing ratings, and 150% sizing.
This is a macOS SwiftUI component render, not an iOS MapKit screenshot. Device
animation quality, GPU cost, and frame pacing remain unverified.

### Earlier camera and transition work

The drag path now stores native camera feedback without publishing it back to
SwiftUI; programmatic camera commands remain observable. Existing projected points
also supply marker reservations, avoiding duplicate `MapProxy` conversions.
The earlier split between compact/photo views and bottom map attachment was
reverted after the reported animation regression. All styles now use one stable
artwork hierarchy and centered map attachment; host sizing and artwork morph
together. New annotations have a small bottom-up entry; retirement only fades.
Equal-priority badges keep their visibility advantage. The default render budget
is 110 active plus 22 retiring annotations; Reduce Motion removes retirees immediately.

The supplied crash stack reached `MapProxy.convert` from deferred refinement.
Models no longer retain a proxy. Live map callbacks capture plain Sendable
coordinate snapshots, and delayed refinement only consumes those values.
Filter, selection, size, and data changes invalidate pending work and request a
fresh capture. This removes the reported call path; the device crash has not been
reproduced or verified in Instruments.

### Zoom review — 2026-09-23

- A new gesture now cancels any pending settled layout and refinement before
  applying movement rules. The cancellation does not invalidate the map view.
  Previously, an old settled result could promote markers during a new pinch.
- Ranked candidate collection stops after the configured unique-candidate limit.
  Sorting, selection priority, duplicate handling, and presentation rules remain
  the same; unused candidates no longer allocate another result array or set entries.
- Added checks for all four directional zoom boundaries, 120 jitter samples per
  side at three hysteresis settings, direct multi-level jumps, invalid projection
  values, heading/dateline wrapping, and camera perspective/history preservation.
- Dense landscape and large-text previews complement the existing interactive
  marker morph preview. Reduce Motion behavior is covered by model checks; its
  visual behavior needs the system accessibility setting enabled in Canvas/device.

Paired optimized Swift 6.4 runs on the same development Mac used identical
workloads and produced matching output-count checksums. Candidate-prefix checks
also verify priority order and selection when duplicate records are present.

| Layout level | Median before | Median after | p95 before | p95 after |
| --- | ---: | ---: | ---: | ---: |
| Region | 2.364 ms | 2.238 ms | 2.458 ms | 2.408 ms |
| City | 2.440 ms | 2.295 ms | 2.553 ms | 2.341 ms |
| District | 2.451 ms | 2.270 ms | 2.535 ms | 2.333 ms |
| Neighborhood | 2.536 ms | 2.377 ms | 2.613 ms | 2.859 ms |
| Street | 2.572 ms | 2.391 ms | 2.668 ms | 2.499 ms |

Medians improved 5.3–7.4% in this pair. Neighborhood p95 increased 9.4%; this is
not evidence of uniformly better tail latency or device frame pacing. Raw reports:
[`before`](Performance/Baselines/zoom-review-before-mac.json) and
[`after`](Performance/Baselines/zoom-review-after-mac.json). Their dirty flags are
intentional; source digests identify the compiled algorithm/check sources.
The historical `natural-transitions-mac.json` predates the restored geometry and
should not be used as the comparison baseline for this change.

Projection still occurs on MainActor before the candidate cap. Very large catalogs,
wide viewports, high pitch, and location-triggered projection need device profiling;
the host suite does not measure MapKit conversion or native annotation rendering.

Instruments Points of Interest now includes `Map projection` and `Apply map markers`
under subsystem `com.trip.map`. Inspect these intervals beside SwiftUI and Time
Profiler during a drag to distinguish projection, presentation, and native rendering.

Use the dense map preview and interactive marker preview, then profile a physical
device with Instruments during pinch, rotation, pitch, fast pan, and rapid filter
changes. Check frame pacing, SwiftUI update frequency, memory, and thermal behavior.
Also check Reduce Motion, Dynamic Type, split-screen resizing, offline search,
location permission changes, and background/foreground transitions.

The zoom review passed the standalone checks, seven comparison-tool checks, all
13 benchmarks, and the Debug generic iOS Simulator build with Xcode 27 beta,
Swift 6.4, and signing disabled. No Swift compiler warnings occurred; Xcode reported
its App Intents metadata extraction skip because the app does not use AppIntents.

Run `bash scripts/audit_sources.sh` for the physical source/member/skill line limits
and same-file preview audit. Its SwiftSyntax runner and module cache live in this
repository, under `scripts` and ignored `.build/audit`. No UIKit imports or bridges
were found in the application.

The earlier Release build request was declined; optimized device compilation is
unverified for these changes. Canvas behavior, device frame rate, and final visual
transitions have not been verified. Compilation and algorithm checks do not
establish those results.
