# Dependency ownership and lifetimes

Create live Trips services in `trip/App/Dependencies/AppTripServices.swift` and its
extensions. Feature models accept contracts; they do not construct storage,
intelligence or native-service fallbacks. This makes lifetime and failure policy
visible and lets the same models run with local fixtures.

## Choose the lifetime

| Consumer | Injected boundary | Lifetime |
| --- | --- | --- |
| `TripLibraryModel` | `any TripStoring` | One shared library and revision sequence per store session |
| `TripAssistantModel` | `TripAIClient<any ItineraryPlanning>` | Window-local draft; service factory selects processing mode |
| `TripLookupModel` | `TripAIClient<any TripDetailSearching>` | Window-local query, or isolated intent lookup |
| `TripChecklistModel` | Library, packing model, `TripChecklistEnvironment` | Window-local naming and packing review |
| `TripPackingModel` | `TripAIClient<any TripPackingPlanning>` | Checklist-owned suggestions; on-device service factory |
| `TripCollectionsModel` | Library, `TripCollectionsEnvironment` | Window-local naming, deletion and notices |
| `TripStopOrderModel` | `any TripStopOrderSuggesting` | Isolated proposal; caller owns task cancellation |
| `TripModel` | Library, workflow models, ordering, tracking, optional search factory | One workspace per scene |
| `TripBookingImportModel` | `any TripBookingReading` | Scene-local review, shared reader actor |
| `TripSystemActionsModel` | `any TripSystemActionProviding`, library | Scene-local review, shared native adapter |
| `TripWeatherModel` | `any TripWeatherProviding` | Scene-local review, shared configured provider/cache |
| `ExploreModel` | `PlaceProviding`, `MapConfiguration` | One map per window; repository owns its cache |
| `DirectionsModel` | `DirectionsProviding`, `DirectionsEnvironment` | Host-retained routing session |
| `TripPlaces.PlaceTextSearch` | Query or native completion | Caller-owned cancellable native operation |

`AppRuntime` retains the durable library and system publisher. AppTripServices
creates each scene's workflow models and isolated assistant/lookup models for
intents. AppModel connects Explore and Trips with weak callbacks; neither feature
owns its sibling. Tracking models are scene-local facades over the shared journey
runtime. See [App](App.md) for activation and publication.

## Availability and failure policy

`TripAIClient` is an immutable MainActor value containing a typed factory,
availability policy and error-to-message function. Workers are Sendable actors or
values. The live host combines entitlement policy with `TripAIAvailability`;
`TripAIFailure` maps service failures inside TripIntelligence. Trips imports neither
FoundationModels nor TripIntelligence. A failure never silently selects a different
live service.

Trips receives `makePlaceSearch` explicitly in production. Omitting the optional
factory keeps saved/local picker behavior available without live MapKit text
search. TripPlaces owns native operation cancellation and conversion;
`Shared/Places` owns autocomplete tokens and app presentation. Each feature retains
its debounce, timeout, selection and stale-result policy. See [Search](Search.md).

AppTripServices retains the booking reader, configured weather provider and
MainActor system-action adapter across scenes. EventKit and the export/alarm ledger
are initialized on first use. Permission prompts belong to explicit user actions.
Durable saves and foreground activation reconcile alarms with current bookings.
Import and forecasts reject cancelled or stale results.

The checked-in configuration injects `UnavailableTripWeatherService`. A host
explicitly enabled and provisioned for WeatherKit can inject
`AppleTripWeatherService`. Private Cloud Compute is also disabled by host policy.
See [Native travel services](NativeTravelServices.md) for review and failure behavior.

## Focused workflow callbacks

Checklist owns its naming draft and packing session. Its environment supplies
feedback, Reminders review and entity identifiers. TripModel includes Checklist's
editing state in navigation protection; suspension cancels generation while keeping
the review visible.

Collections owns naming/deletion sessions and saved-place mutations. Its environment
supplies map navigation, feedback, save-sheet notices and the parent's day-insertion
policy. Selecting another trip clears focused presentation, not saved data. Both
workflows share only the library and use weak parent captures in their callbacks.

## Local composition

Use `PreviewTripServices.makeTrips(plans)`, `makeChecklist(plans)` or
`makeCollections(plans)` for the smallest component under review. Each creates an
isolated PreviewTripStore and local providers. They do not open SwiftData, invoke
Foundation Models, prompt for permissions or fall back to live place search.
Native maps may still need system basemap data. Full ContentView previews use live
composition and are labeled accordingly.

[Preview support](PreviewSupport.md) lists factories and [Testing](Testing.md)
describes controlled test providers. For a new dependency, define the owning
contract, inject it from App, provide a local fixture, and document availability,
cancellation and lifetime here. Follow [Contributing](../CONTRIBUTING.md) for checks.
