---
name: trip-map-decluttering
description: Improve Trip's native MapKit annotations, zoom transitions, collision placement, camera performance, safe areas, and place search.
---

# Trip map behavior

For framework detail, read only the maps/motion topics in the installed global `app-development` skill. Follow the project [rules](../../../AGENTS.md); for empty maps, search, or control changes read [regression diagnosis](references/launch-and-regression-review.md).
For directions, sheets, controls, or Legal placement, read [the integration guide](references/directions-and-safe-areas.md). For observation and identity changes read [Trip state contracts](../trip-swiftui-vcm/references/state-ownership.md).

## Find the owning code

- Zoom thresholds and hysteresis: `Packages/TripKit/Sources/MapEngine/Configuration/ZoomLevel.swift`.
- Shared visual dimensions: `Packages/TripKit/Sources/MapEngine/Layout/MarkerStyle.swift`.
- Collision footprints: `Packages/TripKit/Sources/MapEngine/Layout/MarkerGeometry.swift`.
- Priority and representation choice: `Packages/TripKit/Sources/MapEngine/Layout/MarkerLayoutEngine.swift`.
- Projection and scheduling: `trip/Features/Explore/Models/Explore/ExploreModel+Layout.swift`.
- Search lifecycle stays in Explore; caching belongs to `Packages/TripKit/Sources/MapEngine/Catalog/PlaceRepository.swift`.

## Placement invariants

- Keep exactly three zoom stages: dot, compact icon/image, and labeled view.
- Selection preserves zoom/collision appearance; selecting a dot zooms to at least the icon/image level.
- Project with `MapProxy`; do not approximate screen coordinates using latitude spans.
- Keep MapProxy inside the live MapReader callback; never retain it in models or delayed tasks.
- Finish conversions before publishing state; deferred work requests a fresh live projection.
- Account for camera rotation, pitch, viewport size, and accessibility scaling.
- Keep rendering and collision footprints consistent, including label and touch bounds.
- Reserve space for native location, toolbar chrome, and route callouts/destinations.
- Rank deterministically and retain stable place IDs across representation changes.
- Downgrade crowded markers progressively; never move them away from their coordinates.
- Preserve zoom hysteresis and visibility continuity to limit flicker.
- Let native `Annotation` own coordinates, selection, and gesture recognition.
- Use projected points only for collisions; do not add a full-screen marker hit surface.
- Preserve visible artwork identity; fade entries at final size and defer promotion until gestures settle.
- Visibility and representation are separate: an invisible dot must not enter from stale card geometry.
- Use a short fade and one restrained style transition; avoid entry scaling, bouncing, or stacked animations.
- Reduce Motion removes nonessential transitions and camera animation.
- Keep placement work in its actor and reject stale or cancelled snapshots.
- Cancel settled refinements when a gesture begins; coalesce updates before expensive projection.
- Bound candidates before MapProxy conversion and bound mounted retiring annotations as well as visible ones.
- Record native camera feedback without observable writes that rebuild the annotation tree each frame.
- Do not claim exact global optimality or collision avoidance against Apple's road labels.

## Data and verification

Use MapKit for real place details and preserve explicit sample-image/rating labels.
Keep nearby name deduplication and selection identity when merging live results.
Cover zoom reversal, invisible-to-dot entry, dense collisions, selection, reentry, and large text in existing checks/previews.
Build/run benchmarks only when requested; maintain the existing suite and baselines in `Performance/README.md`.
