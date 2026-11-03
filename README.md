# Trip map

SwiftUI + MapKit, targeting iOS 27 with Xcode 27 / Swift 6.4. Swift 6 language
mode, complete concurrency checking, and default MainActor isolation are enabled.
No UIKit bridges, third-party packages, or app test targets. The standalone
[performance suite](Performance/README.md) runs repeatable algorithm checks and benchmarks.

The app is organized by feature and backed by six local Swift package targets:
TripLocalization, TripDomain, TripRouting, MapEngine, TripStorage, and TripIntelligence. See
[ARCHITECTURE.md](ARCHITECTURE.md) for boundaries and [CONTRIBUTING.md](CONTRIBUTING.md)
for the first-change workflow, independent work areas, and focused builds.
Run `bash scripts/check.sh` for source-only validation. Each feature has a guide in `docs` describing its entry points, state owners, and integration contract.

## Develop and extend

Start with [the development workflow](docs/Development.md). Discover an owner with
`python3 scripts/workspace.py list`, then export focused context with
`python3 scripts/workspace.py context Trips --json`. The repository includes
feature scaffolding, task/decision templates, dependency rules, local preview
services, and documented seams for future tests. Production Trips services are
composed in `AppTripServices`; features receive explicit contracts.

## Run and preview

Open `trip.xcodeproj`, choose the `trip` scheme and an iPhone or iPad, then Run.
Every view file contains named `#Preview` declarations. Use Xcode's Canvas and
Live mode for feedback. `PlaceMarkerView.swift` includes an interactive picker
that animates through all three appearances. `ExploreMapView.swift` previews each
map scale. Other previews cover dark appearance, long titles, unrated places,
active filters, loading, offline messaging, and accessibility text sizes.

`PreviewFixtures` uses bundled data and disables automatic network searches.
The two `ContentView` previews intentionally exercise the complete live app.

Run `bash scripts/annotation-preview.sh` to render the actual annotation components
in light and dark mode without a simulator. The script uses the installed macOS SDK,
SwiftUI ImageRenderer, and bundled assets; images and caches stay in
`.build/annotation-preview`. This component gallery covers all treatments, selection,
long names, missing ratings, and 150% sizing. It does not render MapKit or animations.

## Behavior

- Native Apple map: pan, pinch, rotate, pitch, standard cartography with automatic emphasis,
  realistic elevation, and Apple's attribution.
- Overview: colored dots.
- Medium zoom: compact circular icons or images, with dots in crowded areas.
- Close zoom: labeled views with name, rating and review count; collisions fall
  back to compact icons/images, then dots. Live results use category icons rather
  than unrelated sample photography; bundled sample places can show sample images.
- Selected annotations gain a category-colored outline without resizing or
  changing their category symbol. Selection respects the current zoom level.
- Transparent Explore navigation over a full-screen map: search and one map menu,
  with category multiselection, loaded counts, and scale presets. Native MapKit
  controls provide current location, compass, and scale.
- Native safe areas keep map controls and Apple's logo/Legal link clear of persistent
  navigation and tabs. Temporary notices, bottom sheets, and the keyboard leave
  attribution fixed; route framing still accounts for the exposed map around sheets.
- Back, orientation reset, clear-search, and retry actions appear when relevant.
  Search uses the original inline map bar with one presentation binding and native
  toolbar visibility. Close and user map gestures dismiss search; query changes
  and search completion do not activate it.
  Search progress is delayed for quick/cached results; requests time out after 15 seconds.
  Text searches show their matching places; clearing search restores the loaded
  catalog. Explicit retries request fresh results and timeouts cancel native work.
- Return to the previous camera area, explore in 3D, or face north on a flat map.
  Camera timing follows travel, zoom, and orientation changes; small corrections
  settle faster. Selected places pan just far enough to clear a sheet, accounting
  for their full annotation size. Camera motion respects Reduce Motion.
- Choose Standard, Satellite, or Hybrid in the map menu, with traffic on supported
  styles. Each window remembers its appearance without resetting the map camera.
- Tap any marker for details; tapping a dot zooms to at least the icon/image level.
  Tap another annotation to update the open detail sheet without dismissing it first.
  Place Details presents its name and primary actions above native contact rows.
  Other Places Here opens coincident places and places hidden beneath the marker. The native list shows
  the current selection, and choosing another place opens its details with placement priority.
  Place actions include a close-up camera move, nearby category discovery,
  directions, or the native share sheet. Directions also appear in the context menu.
  Look Around loads native street-level imagery on request where coverage exists,
  with cancel, retry, and explicit no-coverage states. Address, website, and phone
  actions use available MapKit metadata; a 3D action focuses the selected location.
- Map details, filter rows, and notices share spacing values. Search notices use a
  short fade; selection feedback occurs when choosing a place, not when closing it.

The map starts over Bangkok. The native user annotation represents an authorized
device location; the starting camera coordinate is never used as My Location.
The Trips tab provides the full local planning workspace; map actions stay in the
native toolbar, sheets, menus, and context menus where they are easiest to reach.

### Directions

A native bottom sheet shares the system theme of Place Details and Save to Trip,
with compact, 55%-height, and expanded states;
swipe-to-dismiss is disabled by default and an explicit Close button remains available.
It provides travel modes, My Location and destination,
up to five searchable/reorderable stops, a native alternative-route picker, ETA, distance, and route
instructions. Endpoint rows open Change Stop; the grabber controls sheet resizing.
Driving, walking, and cycling modes draw MapKit polylines;
the selected route has a blue stroke and alternatives have tappable duration labels.
Toll/highway preferences and departure/arrival dates affect in-app requests.
Location denial, loading, unavailable routes, and retry have explicit states.
Changing a route, closing the sheet, or leaving the scene cancels obsolete requests.

MapKit returns transit ETA rather than transit polylines. Open in Maps continues
in Apple Maps for navigation and transit departures. The UI only exposes options
that affect in-app requests; Maps-only preferences remain in the reusable URL API.
Multistop estimates combine sequential legs and do not include time spent at stops.
The Maps handoff uses the current device location and its own route/time selection.
Ride-hailing and walking elevation profiles are not exposed by MKDirections.
Direction previews use clearly identified local sample routes without live requests.
The routing package and independent SwiftUI feature can be reused without Explore.
[DIRECTIONS.md](DIRECTIONS.md) documents configuration, injection, lifecycle,
platform limits, focused package tests, and the device verification checklist.

## View–Controller–Model

Views render state and send actions to small struct controllers. Each controller
stores only its model. `ContentView` retains `AppModel`, which composes Explore,
Trips, and app navigation through explicit host callbacks. `ExploreModel` composes
camera, catalog, filter, location, directions, and layout; `TripModel` composes
library persistence, transient presentation, assistant state, and feedback.
Model extensions orchestrate the workflows; features do not own sibling state.

MapEngine’s `PlaceRepository` merges data and builds geographic indexes on its actor, with a
bounded five-minute cache by default. MapKit's search objects stay on MainActor;
only Sendable place snapshots cross the actor boundary. Debouncing, cancellation
and generation checks reject stale results. Work stops while the scene is inactive.
Equivalent camera-end callbacks reuse the completed search; meaningful pans, zooms,
query/filter changes, and explicit retries refresh it. Camera jitter cannot restart a loader.

## Decluttering

An antimeridian-aware geographic index narrows candidates before `MapProxy`
projects them, including rotation and pitch. Native annotations own placement,
selection, and gestures. `LayoutScheduler` keeps one running layout and one
replaceable pending request. A new gesture cancels obsolete settled work before
it can promote markers. Gesture-driven layout runs at most every 80 ms,
accumulates 24 points of pan by default, and receives a final pass when a gesture ends.
Rotation, pitch, and zoom changes have their own tighter thresholds.

Ground meters per screen point select the zoom mode. A 12% hysteresis band keeps
small pinch reversals from flickering between modes. Candidates are ranked by
importance, previous visibility, selection and distance from the viewport center.
The engine tries progressively smaller representations against a 64-point
spatial hash, with footprints shared by rendering and collision calculations.
Existing markers can downgrade while a gesture is active; promotion waits until
the camera settles, including when a pinch crosses a zoom boundary.
Toolbar chrome, the current location, route callouts, and route destinations reserve
screen space. Photos have a screen
area budget; active markers are capped at 110, with up to 22 additional retiring
annotations. Geographic candidates are capped at 600 before projection, retaining
the selection and visible places. Native annotations and collision bounds share a
center attachment. Visible marker styles use one short ease-in-out size transition;
all entering and retiring markers only fade, without scaling. New markers enter as
dots during camera movement; larger treatments wait until the camera settles.
Zoom boundaries at 45 and 3.5 meters per screen point use hysteresis to resist jitter.
An initial layout can project without a camera callback and retries while the native
map attaches. Native view remounts preserve visibility instead of replaying entry.
Only genuinely retired markers start a fresh presentation at their chosen size.
Temporary sheets and notices do not participate in marker removal; sheet geometry
is coalesced for selection framing. Deferred refinement uses
plain coordinate snapshots; `MapProxy` stays within live map callbacks.
Rendering, collision reservations, and retirement share configurable timing,
while selection changes only the outline. Shrinking markers retain their previous footprint
until the morph or fade finishes; promotion uses extra collision clearance.
Steady markers no longer reserve duplicate footprints, and selection can take priority
over a neighbor's temporary reservation without bypassing permanent chrome exclusions.
Reduce Motion disables morph animations. Annotation sizing follows Dynamic Type
up to 150%; the detail sheet provides unrestricted text sizing.
The three appearances share one horizontal artwork hierarchy, an adaptive solid
surface, and a single soft shadow. Invisible minimum touch bounds participate in
collision checks; selection leaves these bounds unchanged.

This is a bounded greedy placement heuristic, not an exact global optimization.
Apple does not expose road-label geometry to this custom collision layer.

## Data and extension points

The live map starts without sample places and loads real results through MapKit.
When nearby results concentrate around one block, one bounded area-wide discovery
request fills out the visible area without moving the camera. See
[launch discovery](docs/Explore.md#launch-discovery-and-map-ui-review--october-18).
Live search supplies actual names, coordinates, categories, addresses, websites
and phone numbers. Matching nearby names retain stable IDs. Place details do not
show sample photographs or ratings. `Resources/Places.json` is used only by local
developer previews; removing live seeds does not delete the user's saved trips.
Counts describe loaded places rather than the total businesses in a region.

Place details and directions use native resize-first sheet scrolling. A stable
navigation stack owns the place sheet: nearby lists, nearby category searches,
and other place details push onto that stack, so Back restores the prior screen.
Selecting a different map annotation starts a new root; selecting within the sheet
preserves the root and updates the selected map marker. Nearby searches are scoped
to their screen, cancel on navigation/backgrounding, and have a 15-second timeout.

Use `MapExperienceView`, `MapConfiguration`, and `PlaceProviding` to compose another
map feature. [REUSE.md](REUSE.md) covers providers, policies, and custom detail UI.
Add categories in `PlaceCategory` and its MapKit mapping; tune geometry in
`MarkerStyle` and zoom thresholds in `ZoomLevel`.
Use a licensed provider to supply real media or ratings. Native Look Around uses
MapKit's street imagery and controls; no Apple Maps photo or ratings scraping is used.

[PERFORMANCE.md](PERFORMANCE.md) records measurements, checks, and remaining device validation.

Trip planning, local SwiftData storage, the on-device itinerary assistant, and App Shortcuts
are documented in [TRIPS.md](TRIPS.md). Trips are intentionally local in this version.
Saved-trip Siri actions, Apple Intelligence context, configurable widgets, and
Dynamic Island trip day tracking are documented in [SYSTEM-INTEGRATIONS.md](SYSTEM-INTEGRATIONS.md).

## API references

- [MapReader](https://developer.apple.com/documentation/mapkit/mapreader)
- [Camera updates](https://developer.apple.com/documentation/swiftui/view/onmapcamerachange(frequency:_:))
- [Local search](https://developer.apple.com/documentation/mapkit/mklocalsearch)
- [Native sharing](https://developer.apple.com/documentation/swiftui/sharelink)
- [Camera orientation](https://developer.apple.com/documentation/mapkit/mapcamera)
- [Directions](https://developer.apple.com/documentation/mapkit/mkdirections)
- [Unified Maps URLs](https://developer.apple.com/documentation/mapkit/unified-map-urls)

## Project guidance

[AGENTS.md](AGENTS.md) defines the project's architecture, size, preview, and build rules.
Project-local skills live in `.agents/skills`: `trip-swiftui-vcm`,
`trip-map-decluttering`, `trip-previews-build`, and `trip-system-integrations`.
Each skill file is at most 50 lines.
