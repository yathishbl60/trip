# TripKit

Eight local Swift package products provide the reusable parts of Trip:

- `TripLocalization`: shared localized resources and typed text accessors.
- `TripDomain`: Sendable values, TripLimits, saved-place selection, injectable service contracts.
- `TripPlaces`: cancellable native text search, MapKit item conversion, and place-category mapping.
- `MapEngine`: collision layout, zoom policy, geographic indexing, catalog merging and caching.
- `TripRouting`: native requests, route values, leg assembly, Maps links, SwiftUI directions UI, route map content, and framing geometry.
- `TripIntegrations`: bounded booking extraction, explicit Calendar/Reminders exports, native alarms, and visit-time forecasts behind domain contracts.
- `TripStorage`: local SwiftData actor; model records never escape this target.
- `TripIntelligence`: itinerary, packing, detail lookup, local stop ordering, and service error presentation behind domain contracts.

Implementation targets depend on TripDomain and TripLocalization. No target depends on the
app or its assets. TripRouting owns its independent observable directions state.
The package uses Swift 6 language mode with the same default actor isolation as
the app and targets iOS/macOS/visionOS 27.3. Directions UI supports iOS and visionOS;
the routing engine and geometry also compile for macOS.

Consumers import the product they use; imports are not re-exported. Add TripDomain
when referring to values such as Place, TripPlan, or their service protocols.
The Xcode app links all eight local products, so no package registry is involved.

## Independent work areas

| Target | Start with | Preserve |
| --- | --- | --- |
| TripLocalization | Resources/Localizable.xcstrings, TripText | Shared text resources and generated accessors |
| TripDomain | Places/PlaceProviding, Trips/TripStoring, Trips/ItineraryPlanning, Trips/TripStopOrderSuggesting | Sendable values, Codable compatibility, small public contracts |
| TripPlaces | PlaceTextSearch, PlaceFactory, PlaceCategory+MapKit | MainActor native requests, place identity/contact values, per-request cancellation |
| MapEngine | Layout/MarkerLayoutEngine, Catalog/PlaceRepository | Stable IDs, bounded work/cache, cancellation, shared geometry |
| TripRouting | DirectionsProviding, DirectionsCalculation, DirectionsPlan | MainActor native objects, per-workflow cancellation, stable route identity |
| TripIntegrations | TripBookingReading, TripSystemActionProviding, TripWeatherProviding | Explicit permission requests, bounded work, stable export identities, stale-result rejection |
| TripStorage | TripStore → TripDatabase → StoredTrip | Migration, rollback, revision rejection, private SwiftData schema |
| TripIntelligence | TripPlanningService → ItineraryDraft | Cancellation, supplied-place validation, private generation schema |

PlaceRepository requires a PlaceProviding implementation; the app's
ApplePlaceProvider supplies live MapKit search results. The package does not
choose an app bundle or import Explore. Hosts create and retain the public
DirectionsModel and inject location, search, presentation callbacks, and colors.
See [directions integration](../../DIRECTIONS.md); no app source copying is needed.
TripLimits centralizes trip
editing policy; change consumers together if a public limit changes.

Coordinate changes to public domain contracts before parallel implementation.
Keep schemas, MapKit task holders, and generated Foundation Models types private.

## Shared native place adapters

TripPlaces depends only on TripDomain, TripLocalization, and Apple frameworks.
`PlaceTextSearch` exposes text and native-completion searches plus cancellation;
the host supplies it through `PlaceSearching` and the caller retains the operation.
`PlaceFactory.make` converts an MKMapItem into
a Place, and `PlaceCategory.mapCategories` supplies search filters. The native
request handle and reverse category lookup remain internal.

Reusing a search replaces and cancels its previous native operation. Cancelling
the calling task or invoking `cancel()` prevents that operation from publishing a
result. Completion cleanup is scoped to the originating operation, so an older
request cannot clear or cancel a newer one. Features still own their UI generations.

Explore and Trips use these adapters. The app's Shared/Places owner retains
observable autocomplete state, completion tokens, annotation text, and colors
from app assets. Feature models retain search debounce, timeout, generation,
selection, and navigation. TripPlaces reads no app resources and imports no
feature types; it is not an extracted Explore or Trips feature.

AppTripServices injects the search factory into Trips. Local previews omit that
capability, so constructing a picker or editing its query cannot start live search.

`Tests/TripPlacesTests` exercises conversion and category mapping through public
imports with local MKMapItem values. Those tests make no network requests; they
do not verify live search, autocomplete, or rendered map behavior.

Run `bash scripts/check.sh` at the repository root after source changes. When a
build is requested, `bash scripts/build.sh <Target>` compiles that target and its
dependencies on the host Mac. These checks do not verify iOS UI integration.
Existing routing tests are documented in [DIRECTIONS.md](../../DIRECTIONS.md);
algorithm checks and performance baselines live in [Performance](../../Performance/README.md).

See [architecture](../../ARCHITECTURE.md) for dependency rules and
[contributing](../../CONTRIBUTING.md) for focused builds and source checks.
