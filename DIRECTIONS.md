# Directions integration

TripRouting contains the complete reusable directions engine, SwiftUI feature,
route rendering, and map geometry. The engine supports iOS 27, macOS 27, and
visionOS 27; the existing sheet and map UI support iOS and visionOS.

## Contents

- [Routing package](#routing-package)
- [SwiftUI feature](#swiftui-feature)
- [Access boundary](#access-boundary)
- [Sheet and interaction behavior](#sheet-and-interaction-behavior)
- [Platform limits](#platform-limits)

## Routing package

Add the local `Packages/TripKit` package and its `TripRouting` product to another
app. `TripRouting` depends only on `TripDomain`, Apple's geographic types, and
system frameworks. It never imports Trip's app types, navigation, storage, or resources.

The public engine API exposes input values (`RouteWaypoint`, `TravelMode`,
`DirectionsOptions`, `DirectionsTiming`, `TransitPreference`), calculation
(`DirectionsPlan`, `DirectionsProviding`, `MapDirectionsService`,
`DirectionsCalculation`, `DirectionsResponse`, `DirectionsFailure`), and results
(`DirectionsRoute`, `DirectionsEstimate`, `DirectionsStep`). MapsDirectionsLink
exposes only its constructor and URL; its stored inputs are private.

```swift
let service = MapDirectionsService()
let destination = RouteWaypoint(id: "museum", name: "Museum", coordinate: coordinate)
let plan = try DirectionsPlan(origin: currentLocation, places: [destination],
                             mode: .walking, options: DirectionsOptions())
let responses = try await DirectionsCalculation(provider: service).calculate(plan)
let routes = try DirectionsRoute.alternatives(responses) { Date.now.addingTimeInterval($0) }
```

Run request orchestration on MainActor because MapKit response objects remain
actor-owned. Cancel the calling task to cancel its native request, or call
`service.cancel()` to cancel all requests belonging to that service. Use one
provider instance per independently cancellable workflow. Providers injected for
other backends or tests must honor cancellation. `DirectionsPlan` creates fresh
native requests; do not share mutable request objects between workflows.

Transit returns `DirectionsResponse.estimate`; it cannot be passed to
`DirectionsRoute.alternatives`. Arrival planning calculates legs backwards;
departure planning calculates them in order. Alternatives combine up to three
choices across the legs, with estimates based on sequential leg requests. They
are not an exhaustive route optimizer and exclude time spent at stops.

## SwiftUI feature

Link `TripRouting` and `TripDomain` from `Packages/TripKit`; no source copying is
needed. Import both products where their types are used. `TripRouting/Feature`
contains the sheet, map content, controllers, models, and DEBUG preview fixtures.
The feature has no Explore, Trips, catalog, camera-model, shared-theme, or storage
dependency. Views use a struct controller storing only the composed DirectionsModel.

Create and retain one `DirectionsModel` at the host's composition root. Inject:

- `DirectionsConfiguration`: travel modes, stop limit, request/location deadlines,
  compact height, and whether interactive dismissal is permitted.
- `DirectionsEnvironment.locationAuthorized`: report whether location permission
  is currently granted. It defaults to false; opening directions must not request permission.
- `currentLocation` and `requestLocation`: supply a fresh, authorized coordinate
  and start the host's location workflow only when My Location is selected.
- `loadedPlaces` and asynchronous `search`: provide local suggestions and remote
  results as `TripDomain.Place` values with stable identities.
- `close`: clear the host's sheet presentation and release location work it owns.
- `sheetFrameChanged`: receive the sheet's global frame for map fitting and occlusion.
- `placeTint`: optionally adapt annotation fills to the host's categories. Use a
  color that keeps native marker glyphs readable; endpoint rows use soft tinted surfaces.
- `appearance`: inject `DirectionsAppearance` to choose route, selected callout,
  callout text, and prominent action colors. The default keeps blue routes and a
  darker blue fill with white text; Trip injects its teal action fill. Keep callout
  text readable against its fill in both appearances. Native secondary surfaces
  and semantic text retain their system colors.
- `DirectionsProviding`: optionally replace Apple's service for integration or tests.

```swift
import SwiftUI
import MapKit
import TripDomain
import TripRouting

let directions = DirectionsModel(configuration: DirectionsConfiguration(),
                                 environment: environment,
                                 provider: MapDirectionsService())
directions.begin(place, origin: environment.currentLocation())
// In the host's sheet:
DirectionsSheetView(model: directions)
// In the host's Map content builder:
DirectionsMapContent(model: directions, scale: 1)
```

When the first location fix arrives, call `directions.acceptLocation(coordinate)`.
Location updates are accepted only while waiting for a selected My Location origin.
For denial or another terminal location error, call `directions.fail(message)` only
if `directions.waitsForLocation`; searched starting points do not depend on location.
Observe `revision` to update map geometry. On a viewport change, call
`requestRouteFit()` and schedule fitting only if it returns true. Use `routeBounds`,
which is nil until a presented route is ready, and call `didFitRoute()` after a
successful camera update. User gestures call `stopFollowingRoute()` so late
responses or sheet resizing cannot move a map the user is exploring. Selecting
another route restores following. Call `suspend()` on inactivity and `resume()`
on activation; do not leave native requests running after removing the feature.

The host supplies its existing Map and applies its own camera transitions. Reuse
`RouteMapGeometry.exposedFrame(in:obstacles:)` with the measured sheet and reserved
regions, then `cameraRect(for:in:exposedViewport:mapSize:)` for the route's bounds.
The result preserves the existing 52-point inset and 200-meter minimum extent.
Call `scheduleRouteFit(isActive:fit:)` to coalesce geometry changes by 180 ms;
the callback uses `routeBounds` and calls `didFitRoute()` after a successful fit.
Call `cancelRouteFit()` on dismissal or inactivity; stopFollowingRoute also cancels it.
`mapExclusions(using:scale:)` supplies the existing callout/endpoint exclusion rectangles
for a host's annotation layout. Call it synchronously in the live MapReader callback.
No map proxy, native camera, app catalog, or location manager is retained by these helpers.
Exclusions cover the same annotated places as the map content, including a searched
starting point, so discovery labels cannot compete with that origin marker.

The public feature types are DirectionsModel, DirectionsConfiguration,
DirectionsEnvironment, DirectionsAppearance, DirectionsSheetView, and
DirectionsMapContent. DirectionsController, DirectionsPresentationModel,
DirectionsStatus, auxiliary controls, and request bookkeeping are internal.
The model exposes read-only `isPresented`, `destinationID`, `maximumPlaces`,
`placeIDs`, `waitsForLocation`, `routeBounds`, and `revision`. The host cannot read
or mutate its raw routes, selection, options, origin, search, or presentation state.
Use `configure(environment:)` when host callbacks require late weak-self binding.

## Access boundary

| Public contract | Reason |
| --- | --- |
| Configuration, environment, appearance, options and their value fields | Hosts construct and customize inputs without package implementation access |
| Routing provider, calculation, request plan, response and typed errors | Hosts can calculate routes without SwiftUI and inject an independently cancellable provider |
| Immutable route/estimate/step values and their constructors | Hosts can consume route results, draw their own maps, or supply deterministic fixtures |
| DirectionsModel lifecycle, location callbacks and read-only host projections | Hosts integrate sheet lifetime, selection, permissions, and itinerary limits |
| Route fitting actions, map exclusions and RouteMapGeometry | Hosts apply camera updates and annotation layout without accessing presentation state |
| DirectionsSheetView and DirectionsMapContent model initializers | Hosts embed the existing UI while its controller remains internal |

Native request arrays, plan bookkeeping, MapKit transport/URL encoding, option
application, callout coordinates, estimate validation, and calculation provider
storage are implementation details. The tests that inspect request construction
or callout placement use `@testable import TripRouting`; test access alone does
not justify a public export. Public-consumer integration tests use a normal import.

TripSystemData's widget/intent links use MapsDirectionsLink with automatic mode,
preserving the original destination-only URL. The widget extension links TripRouting.

## Sheet and interaction behavior

The default sheet has a 100-point compact stop, 55%-height stop, and full-height
stop. Downward dragging resizes it; closing requires its Close button. The host
can opt into interactive dismissal. Compact height is bounded to 100–300 points.
The sheet inherits the system background, matching Place Details and Save to Trip.
Its compact state retains the native Directions title, Options toolbar item, and Close.
Expanded content uses native grouped List sections with system row surfaces and separators.
The native grabber controls resizing; there are no share, overview, or resize buttons.
Accessibility text sizes and compact vertical layouts use the expanded state.
Reduce Motion disables presentation, camera, and value animations.

Explore uses the measured sheet frame for route and selection framing,
including floating sheets. Temporary sheets leave annotation visibility, native map controls, and attribution
at their existing safe-area positions. Route framing adds endpoint padding and offsets
the camera into the exposed viewport. Resizing the window or sheet refits only while
the user is following the route.

Route alternatives use a native segmented picker; large text uses a menu picker.
The route summary has no fixed page height, so content can grow. Steps opens native instructions;
Open in Maps there hands off navigation explicitly. The main sheet shows one route
summary at a time, with destination context above it and travel modes and grouped
endpoints below it. The result stays visible at the standard sheet height. Options
uses a native Form and only exposes settings supported by the in-app route request.
The map header stays clear while loading; discovery progress is a floating notice.
Route fitting coalesces sheet geometry changes, uses the exposed map viewport, and
animates once results are ready rather than first moving to provisional endpoints.

Maps launch failures appear alongside the launch control, including in the Steps sheet.
Each launch has an identity; a late completion cannot update a replaced journey,
dismissed auxiliary presentation, or newer launch. Instruction rows combine their
step number, instruction, distance, and notice for assistive reading. Map route
buttons expose the same disambiguated choices as the sheet, including duration and distance.

Only one auxiliary sheet is active at a time. Endpoint rows open Change Stop;
Add Stop opens search directly. The stop editor retains native delete/reorder controls.
The starting-point row uses the same search picker and can replace My Location with
a place or address. My Location is the default, and offered in that picker, only
when permission is granted. Otherwise the sheet asks for a starting point without
a location spinner or permission prompt. Cancelling search keeps the previous origin;
retry and background/resume retain searched origins. Late device fixes cannot replace them.
The map marks a searched origin and includes it in framing; Open in Maps carries
that coordinate in its native source parameter. A source equal to the destination
retains the existing arrival state instead of starting a redundant route request.
Duplicate identities and locations, invalid coordinates, and stale index operations
are rejected. The default limit is five intermediate stops, configurable from zero
to twenty. Search results are capped at 100 and superseded searches are cancelled.

A route refresh retains compatible geometry and selection while showing an
updating state; navigation and route-choice controls wait for fresh results.
Changing the journey clears incompatible geometry. Stable geometry identifiers
preserve route selection across traffic-only refreshes. Requests and location
waits have deadlines and generations; old responses cannot overwrite newer state.
Already being at a destination has an explicit arrival state.

## Platform limits

Driving, walking, cycling, and automatic modes draw MapKit routes. Transit exposes
ETA only. Toll/highway avoidance and departure/arrival dates affect in-app requests.
The default picker shows driving, walking, transit, and cycling. Automatic routing
remains available to hosts through configuration. Maps-only avoidance preferences
remain supported by the package's URL builder but are not exposed in this UI.
Opening Maps can choose a different alternative and uses its own date/time selection;
the scheduled-time options explain this. Ride-hailing and walking elevation profiles
remain Apple Maps features rather than simulated controls.

`swift test --package-path Packages/TripKit --filter 'RoutingContractsTests|RouteIdentityTests|RoutingCancellationTests|RouteMapGeometryTests'`
checks ordered legs, cancellation, transit handling, invalid/past requests,
avoidance, Maps links, stable route identity, and camera/viewport geometry without
live services. DirectionsFeatureIntegrationTests additionally composes the public
sheet/map API on iOS and visionOS; it is excluded from host-macOS test runs.

Use the source gate in [Contributing](CONTRIBUTING.md). Request compilation and runtime checks separately; source checks do not verify rendered behavior.
