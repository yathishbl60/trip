# Directions

Start at `Packages/TripKit/Sources/TripRouting/Feature`:
DirectionsSheetView → DirectionsController → DirectionsModel. The entire feature
is compiled in TripRouting, which depends on TripDomain, TripLocalization, and system frameworks.
It has no Explore, Trips, app-navigation, storage, or shared-theme dependency.
Its host owns its lifetime; the UI is available on iOS and visionOS.

| Responsibility | Owner |
| --- | --- |
| Endpoints, modes, options, selected route | DirectionsModel and workflow extensions |
| Detents, auxiliary sheets, following intent | DirectionsPresentationModel |
| Search text, results, cancellation | DirectionsStopSearchModel |
| Location/search/close/geometry/tint integration | DirectionsEnvironment |
| Limits and deadlines | DirectionsConfiguration |
| Public host projections and framing actions | DirectionsModel+Host |
| Native requests, cancellation, leg assembly, Maps links | Package TripRouting |
| Route polylines, labels, and endpoints | Feature/Views/DirectionsMapContent |
| Map exclusions and delayed route fitting | DirectionsModel+MapProjection/+MapFraming |
| Exposed viewport and route camera rectangle | Map/RouteMapGeometry |

The controller, presentation model, status enum and raw feature state are internal.
Public views accept DirectionsModel directly. Configuration values, the injectable
provider, routing results and explicit host integration actions remain public.

Inject one DirectionsProviding per independently cancellable flow. The host calls
begin, accepts location, observes revision, frames when requested, and calls
suspend/resume with visibility. Route framing uses routeBounds, requestRouteFit,
didFitRoute and stopFollowingRoute; the host never edits presentation flags.
Never retain MapProxy; the module projects exclusions
synchronously, while the host supplies viewport frames and applies the camera.
Preserve generations and deadlines around every asynchronous
completion. A new selection should not accept a previous request's result.

Use the module's DEBUG DirectionsPreviewFixtures for local route states. Keep the map overlays and
sheet using the same selected route. Transit has ETA but no in-app polyline.
Do not introduce options that native requests cannot honor.

See [DIRECTIONS.md](../DIRECTIONS.md) for the complete public API, package integration
instructions, focused package tests, and device verification checklist. Run
`bash scripts/check.sh` for ordinary source changes; build/tests run when requested.
