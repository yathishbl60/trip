# TripKit

TripKit contains eight local library products. Use the product that owns the
capability you need; imports are not re-exported. Import TripDomain explicitly
when referring to values such as `Place`, `TripPlan`, or their service protocols.

The package uses Swift 6, MainActor default isolation, and iOS/macOS/visionOS 27.3
minimums. Directions UI is available on iOS and visionOS; its engine and geometry
also compile for macOS. There are no remote package dependencies.

## Choose a work area

Paths below are relative to `Sources/<Target>`.

| Product | Start with | Contract to preserve |
| --- | --- | --- |
| TripLocalization | `Resources/Localizable.xcstrings`, `TripText.swift` | Shared translations, deferred resources and generated accessors |
| TripDomain | `Places`, `Trips`, `System` | Sendable values, Codable compatibility, limits and small service protocols |
| TripPlaces | `PlaceSearching.swift`, `PlaceTextSearch.swift`, `PlaceFactory.swift` | Native search cancellation and stable place conversion |
| MapEngine | `Layout/MarkerLayoutEngine.swift`, `Catalog/PlaceRepository.swift` | Stable marker IDs, bounded layout/cache work and cancellation |
| TripRouting | `DirectionsProviding`, `DirectionsCalculation`, `DirectionsPlan` | Native request lifetime, route identity, geometry and host callbacks |
| TripStorage | `TripStore.swift`, `TripDatabase.swift`, `StoredTrip.swift` | Actor-owned SwiftData records, migration, rollback and revision ordering |
| TripIntelligence | `TripPlanningService.swift`, `TripStopOrderService.swift`, `TripDetailSearchService.swift` | Cancellation, supplied-data validation and private generation schemas |
| TripIntegrations | Booking, system-action and weather adapters | Explicit permissions, bounded work, stable export identities and stale-result protection |

TripLocalization depends only on Foundation. TripDomain depends on TripLocalization
and uses Apple geographic frameworks. Every other product depends on those two
targets, without depending on another implementation product or the app. Keep
SwiftData records, generated Foundation Models types, and native request handles
private. [Architecture](../../ARCHITECTURE.md) shows the complete graph.

## Host integration

The host chooses providers and retains UI-facing sessions. `PlaceRepository`
accepts `PlaceProviding`; it does not select an app bundle or import Explore.
`DirectionsModel` receives location, search, presentation and appearance through
its host contract. See [Directions integration](../../DIRECTIONS.md) for that API.

`TripStore` implements `TripStoring`; records and the local-only ModelContainer stay
inside TripStorage. Planning, detail lookup, packing, booking import, native exports
and weather expose domain contracts. The app's `AppTripServices` composes live
providers; [Dependencies](../../docs/Dependencies.md) describes their lifetimes.

Coordinate public domain changes with consumers before implementation. `TripLimits`
is shared editing policy, and Codable defaults are part of persisted-data
compatibility. A package may not reach into app resources to avoid an explicit
contract.

## Native place search

`PlaceSearching` exposes text and native-completion search plus cancellation.
`PlaceTextSearch` retains the native operation; `PlaceFactory.make` converts an
`MKMapItem` into a `Place`, and `PlaceCategory.mapCategories` supplies native filters.
Reverse category lookup remains internal.

Reusing an operation cancels its previous request. Task cancellation or `cancel()`
prevents that request from publishing; cleanup belongs to the originating request
so an old completion cannot clear a newer one. Features still own debounce,
timeouts, selection and UI-generation checks.

Explore and Trips use this package. Observable autocomplete and app colors stay in
`trip/Shared/Places`. Trips receives a search factory from App composition; local
previews omit it and cannot silently start live search. This is a shared adapter
boundary, not a separately compiled Explore or Trips feature.

## Verification

Follow [Contributing](../../CONTRIBUTING.md) for source checks and focused package
builds, and [Testing](../../docs/Testing.md) for existing suites and their scope.
TripPlaces conversion tests use local MapKit values, not live requests. Native
search, routing UI and system services still need their own runtime verification.
The [performance harness](../../Performance/README.md) runs selected production
sources with `TRIP_STANDALONE`; normal app and package builds do not define it.
