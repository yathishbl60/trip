# TripKit

Seven local Swift package products provide the reusable parts of Trip:

- `TripLocalization`: shared localized resources and typed text accessors.
- `TripDomain`: Sendable values, TripLimits, saved-place selection, injectable service contracts.
- `MapEngine`: collision layout, zoom policy, geographic indexing, catalog merging and caching.
- `TripRouting`: native requests, route values, leg assembly, Maps links, SwiftUI directions UI, route map content, and framing geometry.
- `TripIntegrations`: bounded booking extraction, explicit Calendar/Reminders exports, native alarms, and visit-time forecasts behind domain contracts.
- `TripStorage`: local SwiftData actor; model records never escape this target.
- `TripIntelligence`: itinerary, packing, detail lookup, local stop ordering, and service error presentation behind domain contracts.

Implementation targets depend on TripDomain and TripLocalization. No target depends on the
app or its assets. TripRouting owns its independent observable directions state.
The package uses Swift 6 language mode with the same default actor isolation as
the app and targets iOS/macOS/visionOS 27. Directions UI supports iOS and visionOS;
the routing engine and geometry also compile for macOS.

Consumers import the product they use; imports are not re-exported. Add TripDomain
when referring to values such as Place, TripPlan, or their service protocols.
The Xcode app links all seven local products, so no package registry is involved.

## Independent work areas

| Target | Start with | Preserve |
| --- | --- | --- |
| TripLocalization | Resources/Localizable.xcstrings, TripText | Shared text resources and generated accessors |
| TripDomain | Places/PlaceProviding, Trips/TripStoring, Trips/ItineraryPlanning, Trips/TripStopOrderSuggesting | Sendable values, Codable compatibility, small public contracts |
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

Run `bash scripts/check.sh` at the repository root after source changes. When a
build is requested, `bash scripts/build.sh <Target>` compiles that target and its
dependencies on the host Mac. These checks do not verify iOS UI integration.
Existing routing tests are documented in [DIRECTIONS.md](../../DIRECTIONS.md);
algorithm checks and performance baselines live in [Performance](../../Performance/README.md).

See [architecture](../../ARCHITECTURE.md) for dependency rules and
[contributing](../../CONTRIBUTING.md) for focused builds and source checks.
