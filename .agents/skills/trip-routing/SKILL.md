---
name: trip-routing
description: Maintain or reuse TripRouting's directions engine, SwiftUI sheets, route overlays, map framing, stop editing, and Apple Maps handoff without app dependencies.
---

# Trip routing module

Read the project [rules](../../../AGENTS.md) and [integration contract](../../../DIRECTIONS.md); consult the global `app-development` navigation/presentation topics for API detail.
Use this skill for routing changes, extraction, and integration into another host.
Map discovery and general annotation decluttering remain in Explore and MapEngine. For SwiftUI identity and updates read [Trip state contracts](../trip-swiftui-vcm/references/state-ownership.md).

## Find the owner

- `Packages/TripKit/Sources/TripRouting` is the reusable product; import TripDomain explicitly for Place and Coordinate.
- Root sources own requests, options, providers, route identity, legs, estimates, and Maps links.
- `Feature/Models` owns the composed DirectionsModel, search, presentation, and route-fit scheduling.
- `Feature/Controllers` delegates actions; each controller stores only its model.
- `Feature/Views` owns the sheet, supporting controls, route callouts, polylines, and endpoint markers.
- `Map/RouteMapGeometry.swift` owns viewport subtraction and route camera rectangles.
- `Feature/PreviewSupport` owns deterministic DEBUG fixtures; keep previews beside their views.
- Explore owns only host adapters: location authorization, search, sheet lifetime, and camera application.
- Shared/System delegates Maps directions URLs to MapsDirectionsLink; widgets link TripRouting too.

## Reuse without changing behavior

Link the TripRouting and TripDomain products from Packages/TripKit; do not copy app sources.
Retain a DirectionsModel per independent flow and inject DirectionsEnvironment and configuration.
Embed DirectionsSheetView in the host sheet and DirectionsMapContent in its Map builder.
The UI is available on iOS and visionOS; the routing engine and geometry also support macOS.
Keep native MapKit objects on MainActor and mutable requests local to one calculation.
Retain debounce, deadlines, generation checks, cancellation, route selection, and origin semantics.
Keep transit ETA-only and preserve the explicit Apple Maps navigation handoff.
Project mapExclusions synchronously using the live MapProxy; never store the proxy or send it to a task.
Use RouteMapGeometry with measured map, sheet, and reserved-region frames; preserve existing padding.
Schedule route fitting through the model; cancel on gestures, dismissal, and inactivity.
The host applies camera changes and Reduce Motion; package code never reaches into CameraModel.
Pure extractions preserve view bodies, text, modifiers, defaults, and interaction order.
Expose only the host-facing API; keep native request bookkeeping and auxiliary controls internal.
Views accept DirectionsModel; keep DirectionsController, presentation/status types, and raw model state internal.
Use the model's host projections and framing actions instead of exposing mutable presentation flags.
Use @testable for implementation tests; keep public-consumer integration tests on normal imports.

## Verify

Run `bash scripts/check.sh` after boundary changes, including source and skill size checks.
Compare extracted source with its original implementation; source audits do not type-check exports.
When builds are requested, verify app/extension integration and the host-Mac TripRouting target separately.
Host-Mac builds exclude the mobile UI; they cannot prove the public sheet/map API compiles.
Maintain focused routing contract and geometry checks; run tests only within the requested scope.
Report compilation, source comparison, and runtime/visual verification separately.
