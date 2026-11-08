# Dependency ownership and lifetimes

The composition root chooses live services; feature models accept contracts.
This keeps previews local and creates seams for future tests without a global
service registry. Existing window, task, and persistence lifetimes remain explicit.

```mermaid
graph TD
    Runtime[AppRuntime] --> Live[AppTripServices]
    Live --> Store[TripStorage.TripStore]
    Live --> AI[TripIntelligence services]
    Live --> Feature[TripModel and workflow models]
    Feature --> Contracts[TripDomain protocols and values]
    Preview[PreviewTripServices] --> Feature
    Preview --> Local[Local preview actors and value providers]
```

| Boundary | Host supplies | Lifetime |
| --- | --- | --- |
| TripLibraryModel | any TripStoring | One shared library and revision sequence per store session |
| TripAssistantModel | TripAIClient<any ItineraryPlanning> | Window-local state; fresh service for selected processing mode |
| TripLookupModel | TripAIClient<any TripDetailSearching> | Window-local query or isolated intent lookup |
| TripChecklistModel | Shared library, packing model, TripChecklistEnvironment | Window-local naming draft and packing review |
| TripCollectionsModel | Shared library, TripCollectionsEnvironment | Window-local naming, deletion, and notices |
| TripPackingModel | TripAIClient<any TripPackingPlanning> | Suggestions owned by Checklist; on-device factory per request |
| TripStopOrderModel | any TripStopOrderSuggesting | Isolated review; caller owns async task cancellation |
| TripModel | Library, workflow models, ordering service, tracking | One per scene; only durable library is shared |
| ExploreModel | PlaceProviding and MapConfiguration | One map per window; repository owns its cache |
| DirectionsModel | DirectionsProviding and DirectionsEnvironment | Host-retained routing session |
| TripPlaces.PlaceTextSearch | Query or native completion | One caller-owned cancellable MapKit operation |

`TripAIClient` is a small immutable MainActor value containing a typed factory,
availability policy, and error-to-message function. Workers remain Sendable actors
or values. Availability and failures can be controlled independently of device
eligibility in previews and future tests. The live host combines its entitlement
policy with TripAIAvailability. TripAIFailure owns service-specific message mapping
inside TripIntelligence; the Trips feature imports neither FoundationModels nor
TripIntelligence. No optional service silently falls back to a live implementation.

AppRuntime retains the shared library and connects its successful saves to system
publishing. AppTripServices makes each scene's workflow models. Intents construct
their isolated assistant/lookup through the same factory. AppModel connects host
callbacks between Explore and Trips. It does not let either feature own the other.

TripModel composes Checklist with the same durable library and injected packing
worker. Its environment supplies feedback, Reminders review, and system identifiers
without retaining the parent through callbacks. Naming drafts and packing sessions
remain inside Checklist; TripModel includes their editing status in navigation
protection. Suspension cancels generation while retaining the visible review.

TripModel also composes Collections with the shared library. Its environment supplies
map navigation, success feedback, notices for the save sheet, and a callback to the
parent's existing day-insertion policy. Collections owns its editing sessions and
saved-place mutations; callbacks do not retain the parent model. Selecting another
trip clears the focused presentation while preserving saved plans.

Use `PreviewTripServices.makeTrips(plans)` for local Trips composition. Each call
creates its own PreviewTripStore actor and deterministic planning providers.
It never opens SwiftData or calls Foundation Models. Lookup previews return a
fixed stays query; they are fixtures, not a natural-language interpreter. Maps
may still require system basemap data. ContentView previews intentionally use
live app composition and remain labeled accordingly.

Use `PreviewTripServices.makeChecklist(plans)` for Checklist and packing components.
It creates only the focused workflow, local library, and planning provider; it does
not construct TripModel or unrelated workflow services.
Use `PreviewTripServices.makeCollections(plans)` for collection components; it
constructs only a local library and the focused collection model.

Shared code has three separately enforced capabilities: Places, System, and
IntelligenceConfiguration. Explore can consume Places; it cannot reach into shared
system persistence. Widgets consume System and cannot depend on feature models or
inference. App and Trips use only their declared capabilities. DesignSystem owns
visual primitives and has no feature dependency. These are source boundaries in
the app target; reusable packages provide actual compiler-enforced module boundaries.

TripPlaces contains shared MapKit conversion, text search, and category mapping.
Explore, Trips, and the app autocomplete adapter import that product explicitly.
Shared/Places keeps observable autocomplete state and resource-backed presentation.
Each feature retains its debounce, timeout, cancellation, and stale-result policy;
the package neither chooses navigation nor owns a feature's search session.

## Native travel services

AppTripServices retains one booking reader actor, configured weather provider, and MainActor
AppleTripSystemActions adapter. Each scene receives independent import, export, and
weather models. Trips imports only their TripDomain contracts. PreviewTripServices
injects local document, weather, and system-action fixtures without permission prompts.

The system adapter creates and retains its EventKit store and durable export/alarm
ledger on first use, keeping native-service setup out of scene construction.
Successful trip saves and foreground activation reconcile pending alarms with canonical bookings.
Import and forecasts use cancellation plus generation checks. No provider is created
inside a view or silently substituted after a failure. See [native travel services](NativeTravelServices.md).

The checked-in weather-disabled configuration injects UnavailableTripWeatherService.
A host explicitly enabled and provisioned for WeatherKit injects the shared
AppleTripWeatherService actor/cache. Previews always use a local provider.
