# Explore contributor guide

Explore owns map discovery and place presentation. Start at
`trip/Features/Explore/Views/Map/MapExperienceView.swift`, backed by `ExploreModel`.
Its host supplies the detail builder; `AppExploreView` adds trip-saving integration.
Use [Architecture](../ARCHITECTURE.md) for package boundaries and
[Contributing](../CONTRIBUTING.md) for setup/verification.

## Find the owner

Paths below are relative to `trip/Features/Explore` unless a package is named.

| Change | Entry points |
| --- | --- |
| Search/catalog | `CatalogController`, `Models/Catalog`, `ExploreModel+Search` |
| Area results | `MapBrowseController`, `MapBrowseModel`, `MapBrowseItem`, `Views/Map/MapBrowseView` |
| Filters | `FilterController`, `FilterModel`, `Views/Filters` |
| Camera/projection | `MapController`, `Models/Camera`, `ExploreModel+Projection` |
| Annotation placement | `Models/Annotations`, `ExploreModel+Layout`, package `MapEngine` |
| Selection/details | `PlaceController`, `PlaceSelectionModel`, `ExploreModel+Selection` |
| Map style/traffic | `MapAppearanceController`, `MapAppearanceModel`, `MapAppearanceRestoration` |
| Camera restoration | `MapNavigationController`, `MapCameraRestorationModel`, `MapCameraSnapshot`, `MapCameraRestoration` |
| Nearby categories | `PlaceNearbySearchModel`, `NearbyPlaceCategory`, `PlaceNearbySearchView` |
| Look Around | `PlaceLookAroundController`, `PlaceLookAroundModel`, `PlaceLookAroundView` |
| Directions host | `ExploreDirectionsController`, `ExploreModel+DirectionsEnvironment`, `+RouteFraming` |
| Discovery provider | `Services/ApplePlaceProvider`, `MapSearchService`, `MapDiscoverySearch` |
| Native search/conversion | Package `TripPlaces`: `PlaceTextSearch`, `PlaceFactory`, category mapping |

`ExploreEnvironment` is the saved-place boundary: optional `savePlace`, `dismissSave`,
`isSavingPlace`, `savedPlaces`, and `openSavedPlace` callbacks, together with `MapConfiguration.showsTrips`.
Explore does not depend on Trips, storage, or app navigation. Directions sheet,
overlays, and geometry belong to `TripRouting`; Explore supplies its environment
and applies camera changes. See [map composition](../REUSE.md) and
[Directions](../DIRECTIONS.md).

## State and search lifetime

`start()`/`stop()` own the visible lifetime. Catalog generations and activation
revisions reject obsolete results. Inject `PlaceProviding`; `PlaceRepository`
owns bounded caching, merging, and indexing in MapEngine. Native MapKit objects
stay in their service's isolation boundary; workers exchange Sendable values.

Typing uses native autocomplete. Selecting a completion resolves it before opening
an exact place; multiple matches remain choices. Closing search, panning, selecting
another destination, or backgrounding cancels owned resolution and advances its
generation. A submitted map search may finish after the text field closes.
`dismissSearch` is read inside the searchable hierarchy so closing ends keyboard
interaction; the presentation binding remains the activation source.

Compatible results/suggestions stay visible during refinement or a failed refresh.
Clearing the query restores the full loaded catalog. Canonical IDs are resolved
before indexing, preserving existing marker identity. Explicit submission/retry
bypasses repository cache; camera discovery is debounced and cached. Timeouts cancel
the request before releasing its handle. Failed/timed-out areas have a two-second
retry cooldown, not successful five-minute coverage. Explicit retry bypasses it.

A gesture cancels a pending debounce while allowing an active discovery request to
finish. A newer settled area, query, retry, or suspension supersedes that request.
Cached entries retain their original fetch time/area: panning cannot renew stale
coverage or accumulate drift. The bounded LRU accepts successful empty results,
never failed responses. See [Search](Search.md) for matching and shared behavior.

## Launch discovery and controls

The default viewport starts over Bangkok, not the device location. An unfiltered
nearby POI request can cluster all results near the center. The provider may add
one area-wide search when results are empty or confined to the central 30% of
both viewport spans. It uses a Things to do/category query with required region
priority; it does not alter the visible query or camera. Named searches use one
request. Both requests share the cancellable operation and 15-second catalog deadline.
Useful nearby results survive a failed supplement; an empty result plus a failed
supplement reports the error.

The map menu offers Search this area while idle. Failure notices offer Retry;
empty notices explain no results. Active search owns its status instead of also
showing a floating map notice. Filters live in the existing sheet: one adaptive
category grid, a vertical list at accessibility sizes, an All categories reset,
and loaded counts. The map menu shows active filter state without a persistent
category strip over the canvas.

Browse this area opens the existing contextual panel from search or Map options.
`MapBrowseModel` keeps a cancellable snapshot of loaded catalog matches within the
captured ground footprint, using the map's categories and submitted search. It
refreshes after settling; immutable index queries and distance sorting run away
from the main actor. Distances are straight-line distances from the map center.
Selecting a row opens details in the same panel, with Back to results. Row saving
first selects its place so the host's existing detail save sheet owns presentation.
Unprojectable world views ask for closer zoom; late results/dismissals cannot
replace a newer session. A results list does not imply exhaustive MapKit coverage.

Keep `ExploreMapView`'s native location button, compass, and scale in `mapControls`
inside the existing MapReader structure. Do not relocate them to a separate toolbar
host or introduce a duplicate tracking control. Safe areas, attribution, selection,
and camera state must survive resize/fold transitions.

## Projection and placement invariants

- Keep native `Annotation` coordinates/gesture handling and stable place IDs.
  Project with the live `MapProxy`; never retain it or approximate points using
  latitude/longitude spans. Finish conversion before publishing state.
- Retain exactly three stages: dots, compact icons/images, and labeled views.
  Selection preserves its stage; selecting a dot zooms to at least the compact
  stage. Crowding downgrades appearance rather than displacing coordinates.
- Camera feedback is non-observable and detects small accumulated movement.
  Gestures immediately cancel settled refinement; projection remains coalesced
  by movement thresholds and cadence. Zoom updates even with an empty catalog.
- Geographic candidates pass a bounded, deterministic priority buffer before
  projection. A live inverse-projected 3×3 viewport grid reserves half the existing
  budget across geographic cells, then fills by priority. In-view candidates rank
  ahead of overscan candidates. Selection, continuity, filters, and stable ID ties
  remain. Invalid ground geometry falls back to bounded priority ranking; forward
  MapProxy conversion remains authoritative. Not every visible place is guaranteed.
- Test visible artwork separately from collision/touch bounds. Zero-area tangency
  cannot consume a visible slot; partially visible artwork can. Selected labels
  need readable clearance and may fall back to compact artwork at an edge.
- Validate finite obstruction geometry before clipping, including rejection of
  `CGRect.infinite`. Empty sheets must not inflate into obstacles. Clip sheets,
  notices, safe areas, and reserved regions into the live map's coordinate space.
- Geometry changes cancel old placement/refinement immediately, then coalesce a
  fresh projection. Search notices measure their actual pill/control bounds;
  surrounding blank space remains available for map input.
- Unappeared superseded annotations release reservations immediately. Appeared
  annotations retain a bounded fade/retirement lifetime. Separate visibility from
  representation so reentry cannot animate from stale card geometry.
- Reduce Motion suppresses nonessential transitions/camera animation. Keep one
  restrained representation transition and entry fade, without entry scaling.

Ground-scale calibration captures sampled meters-per-point and camera distance
as one pair. Compatible viewport/pitch measurements guide zoom commands; invalid
or changed geometry uses distance presets until a fresh measurement exists.
MapKit remains authoritative. Calibration is an estimate, not an alternate projection.

## Tune at the owning definition

| Decision | Owner |
| --- | --- |
| Stages, hysteresis, zoom targets | `ZoomLevel` |
| Candidate/marker budgets and cadence | `MarkerLayoutPolicy` |
| Collision spacing, image density, continuity | `MarkerLayoutPolicy+Placement` |
| Camera distance, dot selection, 3D focus | `CameraNavigationPolicy` |
| Overscan, ground-scale sampling, movement sensitivity | `CameraProjectionPolicy` |
| Sheet/location exclusions and edge clearance | `MapViewportPolicy`, `MapViewportOcclusion` |
| Fade/morph and retirement timing | `MapMotion` |
| Camera transition duration | `CameraTransitionTiming` in `CameraModel+Motion` |

Rendering and collision geometry must agree. Detailed annotation artwork is
184×64 points before accessibility scaling; its caption uses 110×52 points
(35 title, 3 gap, 14 metadata). Long names truncate rather than shrink, with full
meaning in accessibility/detail content. Unrated places show category metadata.
No photo assets are bundled, so artwork falls back to category symbols even for
saved/sample image names. See [Place gallery](PlaceGallery.md).

## Styles and place details

Standard, Satellite, and Hybrid update the existing Map; Standard/Hybrid support
traffic. `SceneStorage` restores appearance per window without resetting selection,
route, or camera. Place Details uses a leading native sheet on iOS/iPadOS and a
sidebar on visionOS. The exposed map remains interactive. Measured panel bounds
inform framing, including same-size selection changes; the spatial map uses its
column's viewport. Compact detents keep identity/toolbars and the detail path.

`MapCameraRestoration` stores a small validated camera snapshot in per-window
`SceneStorage` at settled camera boundaries. Restoration runs once and yields to
explicit navigation or user camera movement. It does not restore location tracking,
selection, or a route. Persistence timing is owned by the system.

Directions and Save are primary actions; Share and secondary actions stay in the
toolbar. MapKit supplies address, validated website, telephone, and real metadata.
Older saved records can lack telephone values. New live results have no synthetic
ratings; retained sample ratings remain labeled. 3D focus and nearby category
search remain contextual actions.

The host injects saved membership from `TripLibraryModel.savedPlaceIndex`, rebuilt
only for changed trips. Day links open canonical visit details; collection links
open that trip's Collections. Save offers existing memberships and adding elsewhere.
Compact/card artwork carries a bookmark within its existing footprint; dots keep
their size. Saved status is also spoken. Explore never reads storage or Trips types.

Nearby search offers all places, restaurants, cafés, groceries, and attractions
around the selected place using native POI filters. Category changes invalidate
previous results; cancellation, deadlines, distance limits, and retry stay with
`PlaceNearbySearchModel` and the existing search service.

Look Around starts only on request. It owns a native scene request/preview,
distinguishes no coverage from failure, and offers retry/cancel with a 20-second
deadline. Hiding/backgrounding cancels work; generations reject late responses;
coordinate changes clear the old scene. There is no global imagery cache.

## Check an Explore change

Use local `PreviewFixtures.explore`, `hotels`, `dense`, `searching`, and `offline`;
`PreviewFixtures.app` adds saving. Keep previews at the component that owns the state.
Use the [map review workflow](MapEngineReview.md) for placement, identity, and
geometry changes. Algorithm checks live in [Performance](../Performance/README.md).

For an authorized runtime review, include pan/zoom reversal, search selection and
retry, dismiss-during-resolution, filters, selection reentry, sheets/folds,
tracking/compass, route framing, Legal attribution, long text, VoiceOver, and
Reduce Motion. Existing markers or an enabled location button alone do not verify
fresh projection. Source checks do not establish live MapKit behavior or frame pacing.
