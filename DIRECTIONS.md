# Directions integration

`TripRouting` owns the reusable directions engine, SwiftUI sheet, route overlays,
and map geometry. Its package minimums are iOS, macOS, and visionOS 27.3; the
sheet/map UI is compiled for iOS and visionOS. It depends on `TripDomain`,
`TripLocalization`, and system frameworks, never Trip app types or resources.

Use [the owner guide](docs/Directions.md) to find implementation files. This guide
covers the public integration contract. Repository setup and verification commands
live in [Contributing](CONTRIBUTING.md).

## Use the engine

Link the local `TripRouting` and `TripDomain` products from `Packages/TripKit`.
The public API provides waypoints, travel modes, options/timing, a request plan,
an injectable provider, typed responses/errors, and route/estimate/step values.
For example, inside a MainActor workflow with a valid origin and coordinate:

```swift
import TripDomain
import TripRouting

let service = MapDirectionsService()
let destination = RouteWaypoint(id: "museum", name: "Museum", coordinate: coordinate)
let plan = try DirectionsPlan(origin: currentLocation, places: [destination],
                             mode: .walking, options: DirectionsOptions())
let responses = try await DirectionsCalculation(provider: service).calculate(plan)
let routes = try DirectionsRoute.alternatives(responses) { Date.now.addingTimeInterval($0) }
```

MapKit request/response objects remain MainActor-owned. Cancelling the caller
cancels its native request; `service.cancel()` cancels all requests owned by that
service. Inject one provider per independently cancellable workflow. A plan creates
fresh native requests; do not share mutable requests across calculations.

Transit returns an estimate, not a drawable route, and cannot be passed to
`DirectionsRoute.alternatives`. Departure planning requests legs in order; arrival
planning works backwards. Alternatives combine up to three choices across legs.
They exclude time spent at stops and are not an exhaustive route optimizer.

## Embed the feature

Retain one `DirectionsModel` per independent flow in the host's composition root.
The host supplies its existing `Map`, presentation lifetime, and camera changes:

```swift
let directions = DirectionsModel(configuration: DirectionsConfiguration(),
                                 environment: environment,
                                 provider: MapDirectionsService())
directions.begin(place, origin: environment.currentLocation())

// Host sheet or spatial sidebar:
DirectionsSheetView(model: directions)
// Inside the host's Map content builder:
DirectionsMapContent(model: directions, scale: 1)
```

Import SwiftUI and MapKit at those UI sites. `DirectionsConfiguration` controls
modes, stop limits, request/location deadlines, compact height, and interactive
dismissal. Defaults include five intermediate stops, 45-second request and
20-second location deadlines. Limits are clamped to 0–20 intermediate stops and
100–300 points for compact height.

`DirectionsEnvironment` contains only host integration:

| Input or callback | Host responsibility |
| --- | --- |
| `locationAuthorized`, `currentLocation`, `requestLocation` | Report permission and supply a fresh coordinate; request location only after an explicit My Location choice |
| `loadedPlaces`, `search` | Return stable `TripDomain.Place` values from local suggestions or a cancellable search |
| `close` | Clear host presentation and release location work the host owns |
| `sheetFrameChanged` | Capture the sheet's measured global frame for occlusion/framing |
| `placeTint`, `appearance` | Adapt category fills and route/callout/action colors while keeping text readable |

Location authorization defaults to false. Opening directions must not trigger a
permission prompt. Deliver a location fix through `acceptLocation`; call `fail`
for a terminal location error only while `waitsForLocation` is true. A searched
origin remains valid without device location, survives retries/backgrounding,
and cannot be replaced by a late device fix. Search cancellation preserves the
previous origin. Equal origin/destination coordinates use the arrival state.

Call `suspend()` on inactivity/removal and `resume()` when active. Use
`configure(environment:)` for late weak-self binding. Compatible refreshes retain
route geometry/selection while showing an updating state; changed journeys clear
incompatible geometry. Preserve cancellation, deadlines, generation checks, and
stable geometry identity when modifying this behavior.

## Fit routes without taking over the map

Observe `revision` and use read-only `routeBounds`. On viewport changes,
`requestRouteFit()` indicates whether following is still wanted. After applying a
camera update, call `didFitRoute()`. User gestures call `stopFollowingRoute()`;
selecting another route resumes following. A late response or sheet resize must
not move a map the traveler is exploring.

Use measured map, sheet, and reserved-region frames with
`RouteMapGeometry.exposedFrame(in:obstacles:)` and
`cameraRect(for:in:exposedViewport:mapSize:)`. Geometry retains a 52-point inset
and 200-meter minimum extent. `scheduleRouteFit(isActive:fit:)` coalesces changes
by 180 ms; cancel fitting on dismissal/inactivity.

Call `mapExclusions(using:scale:)` synchronously inside the live `MapReader`
callback. It covers route callouts/endpoints, including a searched origin.
Never retain `MapProxy` or send it into delayed work. The package returns value
geometry; the host applies camera transitions and Reduce Motion.

## Preserve the native interaction

- iOS/iPadOS use a leading native sheet with compact, 55%-height, and full-height
  stops. Explore requests a 400-point ideal width. The exposed map stays
  interactive. Close ends directions; dragging changes height. Accessibility text
  omits the smallest stop.
- visionOS uses the same expanded content in a split-view sidebar. Its map column
  supplies the usable viewport. See [adaptive layouts](UNIVERSAL-APP.md), including
  the retained-sheet and fold-transition checks.
- Alternatives use a segmented picker or a menu at large text sizes. Steps and
  endpoint/stop search share the panel's navigation stack; collapsing preserves
  that destination. Options uses a native popover with compact adaptation.
- Search rejects duplicate identities/locations, invalid coordinates, and stale
  index actions. Results are capped at 100; superseded work is cancelled.
- Apple Maps launch failures stay beside the launch action. Launch identities
  prevent late completions from updating a replaced route or presentation.
- Keep system backgrounds, native grabber/resizing, semantic toolbar placement,
  accessible route descriptions, and explicit Open in Maps. Do not add imitation
  navigation, extra resize controls, or options native requests cannot honor.

Driving, walking, cycling, and automatic modes draw routes; transit is ETA-only.
Toll/highway avoidance and arrival/departure dates affect in-app requests.
Apple Maps chooses its own alternative and scheduled-time behavior. Maps-only
avoidance remains a URL-builder capability, not an in-app control. Shared widget
and intent handoffs use `MapsDirectionsLink` with destination-only automatic mode.

## Preserve the public boundary

Public hosts use configuration/environment/appearance, the provider and result
values, `DirectionsModel` lifecycle/read-only projections, fitting actions,
`DirectionsSheetView`, and `DirectionsMapContent`. Controllers, presentation/status
models, raw route selection, search state, and request bookkeeping remain internal.
Tests may use `@testable`; test convenience alone does not justify a public API.

## Check a routing change

Run `bash scripts/check.sh` for source changes. When tests are requested, routing
contract, identity, cancellation, and geometry suites use local providers without
live service requests.
`DirectionsFeatureIntegrationTests` also composes the public UI on iOS/visionOS;
host-Mac tests exclude that UI and cannot establish its compilation. See
[Testing](docs/Testing.md) and the [owner guide](docs/Directions.md).

Report source checks, each platform's compilation, and runtime review separately.
Native acceptance includes origin permission/denial, late fixes, route replacement,
search retry/cancellation, stop editing, sheet resizing, map gestures, attribution,
large text, VoiceOver, and Reduce Motion. Record the exercised cases and any
remaining checks in the change description.
