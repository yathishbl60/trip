# Map composition and reuse boundaries

Trip's reusable values/algorithms live in `TripDomain` and `MapEngine` under
`Packages/TripKit`. `TripPlaces` supplies native search/conversion, and `TripRouting`
supplies directions. These are package products; the SwiftUI Explore host,
controllers, presentation, assets, and `ApplePlaceProvider` are app-owned code.

`MapExperienceView` and `ExploreModel` are composition examples within the app,
not exported package APIs. Reusing the algorithms does not require copying the
Explore feature. For boundaries and dependency rules, see [Architecture](ARCHITECTURE.md);
for the reusable directions UI, see [Directions](DIRECTIONS.md).

## Configure an Explore host

Inside the app module, create and retain `ExploreModel` once outside `body`, then
supply a detail builder to `MapExperienceView`. For example, with an implemented
`HotelProvider`:

```swift
var configuration = MapConfiguration()
configuration.categories = [.hotel]
configuration.showsLocation = false
configuration.sourceName = "Hotel catalog"
configuration.layout = MarkerLayoutPolicy(markerLimit: 90)
let model = ExploreModel(configuration: configuration, provider: HotelProvider())

MapExperienceView(model: model) { place, controller in
    PlaceDetailView(place: place, controller: controller)
}
```

The same-file previews show local hotel and custom-detail composition.
`MapExperienceView` owns scene activation, cancellation, and tool presentation;
its parent retains the model. `ExploreMapView` is the lower-level map for a host
that owns its chrome/lifecycle. Views delegate actions to struct controllers;
models and providers own state and behavior.

Single-category hosts hide category controls. `showsLocation` controls the native
user annotation/location control. Directions has a separate explicit origin and
permission flow; hiding a discovery control does not provide location permission.

## Connect saving without coupling features

`ExploreEnvironment` offers `savePlace`, `dismissSave`, and `isSavingPlace`.
A save-enabled host supplies these callbacks and enables `showsTrips`; a map-only
host can omit them without creating trip storage. The host owns its save sheet
and pending destination. Explore requests an action or dismissal when its
selection/directions changes.

`AppModel` wires the callbacks through Trips' semantic host methods, and
`AppExploreView` supplies root/nested save presentations. Follow this integration
rather than letting Explore read Trips models. See [App](docs/App.md).

## Supply data

Implement the Sendable `PlaceProviding` contract, normally with an actor:

- `initialPlaces()` supplies the starting collection.
- `search(_:)` receives viewport, query, and effective category selection.
- Return stable provider-owned `Place` identities and honor cancellation.

`ApplePlaceProvider` is the production adapter; DEBUG `LocalPlaceProvider` is a
network-free fixture. `PlaceRepository` requires an injected provider and owns
bounded caching, merging, and indexing. The default configuration starts over
Bangkok; it is not a device-location fix.

Native MapKit objects stay in their service's isolation boundary. Sendable values
cross worker boundaries. A provider does not own map navigation, feature search
sessions, or presentation. See [Search](docs/Search.md) for the shared adapters.

## Tune policy at its owner

| Configuration | Controls |
| --- | --- |
| `initialCenter`, `initialDistance` | Starting camera, with finite/range validation |
| `categories`, `initialCategories` | Available categories and initial selection |
| `showsFilters`, `showsLocation`, `showsTrips` | Feature controls and save actions |
| `layout` | Marker/projection budgets, hysteresis, update cadence, permitted appearances |
| `motion` | Morph, fade, camera, and selection transitions |
| `data` | Collection/cache limits, freshness, debounce, nearby-name matching |

Configuration is captured when the model is created. Empty available categories
means all categories; no selected filters means all available categories.
Use `nameMatchRadius: nil` when distinct same-name records must not merge, and
`cacheLimit: 0` when a source must refresh rather than reuse area responses.

Keep the three-stage dot → icon/image → label ladder, native coordinates, stable
identities, and collision downgrade behavior. Default selection retains its zoom
appearance (`selectionStyle: nil`); an explicit card policy still respects edges,
collisions, and gesture stability. `MarkerStyle` owns rendering/collision dimensions.

Pan coalescing defaults to 24 screen points; gesture completion still refreshes.
Rotation, pitch, and zoom have independent thresholds. Retiring annotations are
bounded to one fifth of `markerLimit` (at least one) beyond the active budget;
Reduce Motion removes them immediately. Entries fade without scale animation.
See [Explore](docs/Explore.md) for the full placement and lifecycle contract.

## Limits and contributor checks

The current merge model retains bounded earlier results; it is not a live-presence
or deleted-record stream. Tracking other people, additional path domains, or a
large photo catalog require explicit domain/lifetime work. New place categories
also need symbol/color presentation and a MapKit mapping where applicable.

Live MapKit results have provider metadata and category artwork. Sample ratings
or image names are fixture data, not a photo service. No gallery photos are bundled;
see [Place gallery](docs/PlaceGallery.md). Technical integration instructions do
not establish rights to external catalogs or artwork.

Use local fixtures for source/preview work and follow [Contributing](CONTRIBUTING.md)
for verification scope. Increasing density or cache limits needs appropriate
measurement; configurability alone is not a frame-rate guarantee.
