# Explore

Start at `Views/Map/MapExperienceView.swift`. Its host supplies a detail builder;
`ExploreModel` owns only the map experience. The app's AppExploreView adds saving.

| Work | Entry points |
| --- | --- |
| Search | CatalogController, Models/Catalog, ExploreModel+Search |
| Filters | FilterController, FilterModel, Views/Filters |
| Camera and map callbacks | MapController, Models/Camera, ExploreModel+Projection |
| Annotation placement | Models/Annotations, ExploreModel+Layout, package MapEngine |
| Selection/details | PlaceController, PlaceSelectionModel, ExploreModel+Selection |
| Map styles and traffic | MapAppearanceController, MapAppearanceModel, MapAppearanceRestoration |
| Street-level imagery | PlaceLookAroundController, PlaceLookAroundModel, PlaceLookAroundView |
| Routing integration | ExploreDirectionsController, ExploreModel+DirectionsEnvironment |
| MapKit search and place conversion | Services/ApplePlaceProvider, MapSearchService, PlaceFactory |

ExploreEnvironment is the host contract for saving: optional savePlace,
dismissSave, and isSavingPlace. Supply all three for a save-enabled host. The save
button also respects MapConfiguration.showsTrips. Explore has no Trips, storage,
or app-navigation dependency. Directions UI, overlays, and geometry are provided
by the TripRouting product. Explore supplies only host adapters and camera application.

PlaceProviding is injectable. MapEngine.PlaceRepository owns the bounded cache,
merge, and indexing worker and requires a provider. MapKit objects stay in their
MainActor service; workers exchange Sendable snapshots. Catalog generation and
activation revisions reject stale work. `start()`/`stop()` own the visible lifetime.

Text searches render the latest matching result snapshot, while the full loaded
catalog stays available when the query is cleared. Search merging resolves results
to canonical place IDs before building either index, so a live match keeps an
existing marker's identity. Nearby-place choices use the same visible index.
Compatible cached matches remain visible during refinements and failed refreshes.
Explicit search/retry bypasses the
repository cache; camera-driven discovery remains debounced and cached. A timeout
cancels the owned request before clearing its handle and invalidating its generation.
MapCanvasView reads SwiftUI's dismissSearch action inside the searchable hierarchy;
closing the presentation also ends the native search interaction and keyboard focus.
The presentation binding remains the only activation source.

Resolving an autocomplete suggestion belongs to the search presentation. Closing
search, panning the map, or selecting another destination cancels that resolution
and advances its generation, so a late result cannot reopen details or move the
camera. A submitted text search can continue updating its map results after the
search field closes. Completed requests release their resolution handle.

Fetch activity is observable so suggestion controls and opening-place feedback
update immediately. Retrying autocomplete clears the previous resolution failure;
the native Search places action also remains available when suggestions are
loading, missing, or unhelpful. Existing compatible suggestions remain visible.
Local previews cover resolution loading, failure recovery, and submitted-search
failure. Source validation does not establish keyboard, VoiceOver, or live MapKit
behavior; exercise dismiss-during-resolution, retry, submit, and choose/save on a
device when runtime verification is requested.

Cached word matching, result identity validation, no-results recovery and the
shared behavior across planning searches are described in [Search](Search.md).

## Contents

- [Gesture responsiveness and search continuity](#gesture-responsiveness-and-search-continuity)
- [Calibrated zoom and annotation lifecycle](#calibrated-zoom-and-annotation-lifecycle)
- [Styles and place details](#styles-and-place-details)
- [Launch discovery](#launch-discovery)

## Gesture responsiveness and search continuity

Map options → Filters opens the existing filter sheet. Category buttons share a
Liquid Glass container and stable effect identities in an adaptive grid, with
animated selection symbols and loaded-place counts. Show places dismisses the
sheet; no category strip or summary remains over the map. Active filters remain
visible in the existing map menu's badge and category summary. Accessibility text
sizes use the vertical category list. visionOS uses native bordered controls.

Category controls never reserve canvas space or change native map safe areas,
attribution or camera position. Reduce Motion disables the glass morph and
selection animation. The existing catalog filtering, search scheduling and
selection identities own the actual result updates.

Camera feedback detects movement even when each callback advances by less than a
pixel or a very small zoom step. Activity detection cancels settled annotation
work immediately; expensive projection still uses the accumulated movement
threshold and configured interval. Camera feedback remains non-observable, so it
does not publish a new annotation tree on every frame.

Geographic selection streams candidates through a bounded priority buffer before
MapProxy conversion. It retains only the projection budget, deduplicates stable
place IDs, and sorts that retained set. Selection, continuity weighting, category
filtering, and deterministic ID ties remain in force. Native annotations still
use the same three appearances and live MapProxy coordinates; there are no new
map controls or approximate screen-coordinate calculations.

A gesture cancels a pending search debounce while allowing an active request to
finish. A newer settled area, changed query, explicit retry, or suspension still
supersedes/cancels it through generation checks. Compatible results remain visible
during refresh. Failed and timed-out requests use a two-second retry cooldown;
they do not count as successful five-minute coverage. Explicit retry bypasses the
cooldown and cache.

The repository reuses requests within the existing query/category/area/zoom
tolerance. Cached responses retain their original fetch time and area, so moving
around a cached result cannot extend its lifetime or accumulate coverage drift.
The bounded cache evicts its least recently used area; replacing an existing key
does not evict a second entry. Empty successful responses are cacheable, while
failed requests never enter that cache.

In very dense rotated or highly pitched views, offscreen candidates
can still consume the geographic projection budget; the bounded ranking change
does not claim exact visible-area coverage or device speed measurements.

Keep MapProxy in live MapReader callbacks. Preserve marker IDs, native annotations,
dot/icon/label stages, hysteresis, cancellation, and camera intent. Package geometry
must match rendering. Persistent chrome and temporary sheet occlusion have
different owners; read the project map skill before changing them.

Use PreviewFixtures.explore/hotels/dense/searching/offline. These providers are
local; PreviewFixtures.app includes the save integration. Run source checks after
changes. Requested algorithm checks live in Performance; native gesture, sheet,
and attribution verification remains a separate device/Canvas task.

## Calibrated zoom and annotation lifecycle

The Map Scale choices use `ZoomLevel.preferredMetersPerPoint`, safely inside each
stage's hysteresis band. Explore captures ground scale and the sampled camera
distance together in `CameraGroundScale`; later camera feedback cannot change the
distance paired with that measurement. Compatible measurements adapt zoom commands
and dot selection to the current viewport and pitch. Changed viewport dimensions,
changed pitch, or failed projection use the existing distance presets until a new
measurement is available. Zoom state also updates when the catalog is empty.
Calibration is a local estimate; native MapKit projection remains authoritative.

Layout ranking uses the visible artwork footprint and permitted styles before
applying its candidate cutoff. Invisible touch padding, collision clearance, and
zero-area edge tangency cannot consume a visible marker slot. Partially visible
artwork remains eligible, including subpoint edge overlap. This preserves budget for visible candidates
without changing coordinates or dropping partly visible edge markers. The earlier
geographic projection budget still applies; this does not guarantee every visible
place can be considered in a dense tilted map.

Collision and hit-test bounds remain separate from visual eligibility. Selected
labels still require full readable clearance; they can fall back to compact artwork
at an edge. Invalid/nonfinite exclusions and reservations are rejected before
clipping, including CoreGraphics' infinite-rectangle sentinel. Finite covering
obstacles and a marker's ability to ignore its own reservation remain authoritative.

Measured place/directions sheets and search notices join safe-area and native
reserved-region exclusions in map-local coordinates. Empty sheets are checked
before clearance inflation, off-map rectangles are discarded, and each obstacle
is clipped to the live map frame. Geometry updates cancel obsolete placement and
refinement immediately while coalescing the fresh projection. They do not change
native safe areas, attribution, map controls, or camera positioning.
Search notices report their content/control bounds before the outer centering
frame and padding. The retry target remains at least the platform control size,
while blank space around the pill remains available to map interaction.

Annotations superseded before native appearance release their reservations and
are removed immediately. Appeared annotations retain their fade, collision space,
and bounded retirement lifetime. The existing native identity and Reduce Motion
behavior remain.

### Reading and tuning the map code

Rules are grouped by the decision they control. Numeric values at those definitions
are intentional tuning defaults; calculation sites use names, units, and explicit
stage/visibility decisions. Ordinary geometry such as half a width stays local.

| Decision | Owning code |
| --- | --- |
| Dot → icon/image → label thresholds, hysteresis, zoom targets | `ZoomLevel` |
| Candidate/marker budgets and projection frequency | `MarkerLayoutPolicy` |
| Collision spacing, image density, continuity ranking | `MarkerLayoutPolicy+Placement` |
| Camera distance bounds, dot-selection zoom, 3D focus | `CameraNavigationPolicy` |
| Overscan, ground-scale sampling, movement sensitivity | `CameraProjectionPolicy` |
| Sheet/location exclusions and selection edge spacing | `MapViewportPolicy.swift` |
| Global-to-local obstruction clipping | `MapViewportOcclusion.swift` |
| Fade/morph duration and settling allowances | `MapMotion` |
| Adaptive camera animation timing | `CameraTransitionTiming` in `CameraModel+Motion` |

`CameraSample.differs` names each movement condition separately. `ZoomLevel.resolve`
names each starting stage and its permitted transitions. Layout ranks eligible
places, chooses a collision-free appearance, and reserves its bounds. Marker
reservations are explicit lifecycle state shared with refinement scheduling.

## Styles and place details

The map menu provides Standard, Satellite, and Hybrid styles. Traffic is offered
for Standard and Hybrid, the native styles that support it. SceneStorage restores
appearance per window. Changing a style updates the existing Map rather than
recreating its camera, annotations, or selected route. The style menu remains
available above a place or directions sheet; search and save presentations retain
their existing toolbar behavior.

Detailed annotations preserve a 184×64-point surface and a 110×52-point caption
area before map accessibility scaling. The shared caption metrics allocate 35
points to the two-line name, a three-point gap, and 14 points to metadata. Long
names truncate rather than shrinking below the intended font size; the complete
name/category remains in the annotation's accessibility label and place details.
Unrated places show their category instead of a repeated View details prompt.
Category symbols grow within the existing artwork area at the detailed stage.
No place photographs are bundled, so live, saved, and sample annotations use
category artwork; the leaf artwork view enforces that fallback as well as its host.

Catalog name matching uses the nearest existing place inside the configured
radius, with a stable ID tie-break; an exact provider ID takes precedence. A
refresh near one branch must not move another same-name branch's annotation.
Cancelled merges stop before snapshot preparation, including empty-input merges.
Public proximity queries reject malformed rectangles; indexed queries validate
the viewport once before visiting the retained candidate slice.

See [the MapEngine review](MapEngineReview.md) for concrete findings and verification scope.

Place details keep the native sheet background and detents. Directions and Save
remain the primary actions; Share is directly in the toolbar. Information rows
show an address, validated website, and telephone action when returned by MapKit.
Older saved places decode without a telephone value. New live search results have
no synthetic ratings; previously saved sample ratings remain explicitly labeled.
The exploration section offers a focused 3D camera move and nearby category discovery.

Look Around loads on request, using MKLookAroundSceneRequest and the native
LookAroundPreview with its navigation controls. It distinguishes no coverage from
request failures, offers retry and cancel, and has a 20-second deadline. Requests
cancel when hidden/backgrounded; generation checks reject late completions. A
coordinate change clears the prior scene. The view owns just its current scene;
there is no global imagery cache. Previews cover local idle/loading/failure/no-coverage
states and do not automatically request live imagery. Coverage and native viewer
interaction still require device verification when authorized.

## Launch discovery

An unfiltered nearby POI request can reach MapKit's result limit within a small
central cluster. Decluttering correctly collapses those coordinates, leaving the
rest of a city-scale viewport bare. ApplePlaceProvider now retains those nearby
results and makes at most one supplemental area-wide search if all results lie
inside the central 30% of each viewport span, or the response is empty. The
supplement uses Things to do for all categories, category names for a subset,
point-of-interest results, and required region priority. It never changes the
camera or visible search query. Repository merging retains canonical identities.

Both requests share the existing cancellable operation wrapper and the catalog's
15-second deadline, generation checks, debounce, and cache. If the supplement
fails, useful nearby results survive; an empty response with a failed supplement
reports the error. Named searches still make one request. No sample places,
synthetic coordinates, search fan-out, or durable location tracking were added.

The existing map menu always offers Search this area when idle. Failure/empty
notices distinguish no results from failures; failure notices expose Retry directly.
Active search owns its own status instead of also
showing a floating map notice. Search uses a shorter prompt and primary/secondary
result contrast. Filters use one category grid (a list at accessibility sizes),
All categories to reset, and a loaded-count footer instead of a duplicate summary
panel and Reset action.

Native controls retain their established automatic MapKit hosting. An attempted
control relocation was withdrawn after runtime checks exposed regressions; extra
collision geometry is not a delivered change. App composition shows save
confirmations inside an open place sheet, and above the tab bar when the map
itself is visible.
