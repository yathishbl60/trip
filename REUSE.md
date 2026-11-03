# Reusing the map

The SwiftUI map host lives in `trip/Features/Explore`; its composition boundary
is `MapExperienceView`, backed by `ExploreModel`. Reusable values and algorithms
live in the local TripDomain and MapEngine products under `Packages/TripKit`.
Import both products when composing another map host. The included Directions
integration also requires the TripRouting product and Directions feature. UI, resources, navigation,
and the ApplePlaceProvider adapter remain app-owned.
Create and retain the model once at the feature's composition root, outside `body`.
Views send actions to controllers; providers and models handle data and behavior.

## Contents

- [Configure a feature](#configure-a-feature)
- [Saving in a host](#saving-in-a-host)
- [Data adapters](#data-adapters)
- [Policy controls](#policy-controls)
- [Domain boundaries](#domain-boundaries)

## Configure a feature

```swift
var configuration = MapConfiguration()
configuration.categories = [.hotel]
configuration.showsLocation = false
configuration.sourceName = "Hotel catalog"
configuration.layout = MarkerLayoutPolicy(markerLimit: 90)
configuration.motion = MapMotion(morph: 0.38, fade: 0.18)
let model = ExploreModel(configuration: configuration, provider: HotelProvider())
```

Render the retained model with any detail view:

```swift
MapExperienceView(model: model) { place, controller in
    PlaceDetailView(place: place, controller: controller)
}
```

`MapExperienceView.swift` contains local hotel and custom-detail previews.
`ExploreMapView` is also available for hosts that supply their own chrome/lifecycle.
`MapExperienceView` owns scene activation, cancellation, and sheet presentation.
Its parent retains `ExploreModel` in `@State`; the map host uses that injected
instance directly. The toolbar hides category controls for single-category
providers and keeps the native user annotation and location control conditional
on `showsLocation`. Directions request a fresh authorized origin independently.

## Saving in a host

Explore has no dependency on Trips or app navigation. Supply ExploreEnvironment
with savePlace, dismissSave, and isSavingPlace callbacks when the host supports
saving. Saving controls require both a callback and configuration.showsTrips.
The host presents its save UI and owns the pending destination; Explore only sends
the action and can request dismissal when selection or directions changes.

Trip's AppModel wires these callbacks to TripModel, while AppExploreView supplies
the root and nested-detail save sheets. Use it as the integration example. A custom
map-only host can omit the environment and does not create storage or trip state.

## Data adapters

Implement the Sendable `PlaceProviding` protocol, preferably using an actor:

- `initialPlaces()` returns the starting collection.
- `search(_:)` receives the viewport, query, and effective category selection.
- Both return Sendable `Place` values with stable, provider-owned IDs.
- Honor cancellation; never generate fresh IDs for unchanged records.

`ApplePlaceProvider` is the default; `LocalPlaceProvider` in DEBUG PreviewSupport
supplies deterministic fixtures without network requests. MapEngine.PlaceRepository
requires an injected provider and handles cache bounds, merging, and spatial indexing. Defaults preserve the existing Bangkok experience.

## Policy controls

| Configuration | Controls |
| --- | --- |
| `initialCenter`, `initialDistance` | Starting camera, with finite/range validation |
| `categories`, `initialCategories` | Available categories and initial selection |
| `showsFilters`, `showsLocation`, `showsTrips` | Category filters, location, and place-to-trip actions |
| `layout` | Marker/candidate limits, photo budget, pan threshold, update interval, zoom hysteresis, per-level appearances, selected appearance |
| `motion` | Size transition, visibility fade, camera, and selection-color durations; coordinated cleanup |
| `data` | Collection/cache limits, lifetime, debounce, nearby-name matching |

An empty category list uses all current categories. No selected filters means all
available categories. Appearance policies retain a dot fallback for dense areas.
Configuration is captured at model creation; create another model to change policy.

`ZoomLevel` has three levels: `.region` (dots), `.district` (icons/images), and
`.street` (labeled views). `MarkerStyle` has the corresponding `.dot`, `.thumbnail`,
and `.card` treatments. Both collision downgrades and custom policies use this ladder.
Selection defaults to `selectionStyle: nil`, retaining the zoom level's appearance.
Hosts may opt into `MarkerLayoutPolicy(selectionStyle: .card)` to allow a labeled
selection at distant zoom. It still honors collisions, edges, and gesture stability.

`MarkerStyle` owns artwork dimensions and minimum touch bounds. Its appearance
extension defines the shared horizontal composition, so geometry and SwiftUI
rendering can evolve together. Use the same-file interactive previews and
`scripts/annotation-preview.sh` when tuning a domain's annotation presentation.

`minimumPanDistance` defaults to 24 screen points; accumulated motion is compared
with the last layout, and gesture completion always refreshes. Rotation, pitch,
and zoom still use independent thresholds. The retiring annotation budget is one
fifth of `markerLimit` (at least one), in addition to active markers. Reduce Motion
removes retired annotations immediately. Use `MapMotion(fade: ...)` to tune entry
and exit opacity, and `morph: ...` for visible size changes. There is no entry scale
animation. Selected outlines use `selection: ...` without changing marker size.
Reappearing annotations reset their artwork presentation while retaining their
native place identity. Camera navigation keeps one
previous viewpoint; nearby discovery uses the injected provider and selected category.

For identity-sensitive data, set `MapDataPolicy(nameMatchRadius: nil)` to prevent
different records with similar names from merging. Use `cacheLimit: 0` for sources
that must always refresh. New `PlaceCategory` cases also need symbol/color/photo
presentation and a MapKit mapping when using Apple's provider.

## Domain boundaries

Hotels, places, and activities can adapt their search results directly. The independent
Directions feature composes the TripRouting product and injected host callbacks.
See [DIRECTIONS.md](DIRECTIONS.md) for hosting the package UI or using its engine alone.
Trip paths and friend tracking need additional domain models and UI. Current
search merging retains earlier results up to the configured cap; it does not
implement a live presence stream or deleted-record events.
Those features can extend the provider/model boundary without changing placement.

Live MapKit results use real place metadata and category icons. Preview place data
can contain illustrative ratings and image names; those are not live provider data.
Supply licensed media and source-appropriate details when integrating another catalog. Increasing density or collection
limits requires device profiling; configurable limits are not a frame-rate guarantee.
