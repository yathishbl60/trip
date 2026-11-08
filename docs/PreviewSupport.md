# Preview fixtures

All fixture declarations belong behind `#if DEBUG`. Production code must not
refer to them; the ownership checker rejects direct references outside DEBUG.

| Fixture | Purpose |
| --- | --- |
| PreviewFixtures.swift | Shared places and local Explore states |
| PreviewFixtures+Density.swift | Dense map inputs |
| PreviewFixtures+Trips.swift | TripModel, Checklist, and Collections fixtures with local storage |
| PreviewTripServices.swift | Explicit component composition, independent of live AI |
| PreviewTripStore.swift | Isolated value snapshots without SwiftData |
| PreviewTripPlanning.swift | Deterministic itinerary, packing, lookup, and ordering providers |
| TripPackingPreview.swift | Focused Checklist model with local packing review states |
| PreviewFixtures+App.swift | AppModel with map/save/navigation wiring |
| TripRouting/Feature/PreviewSupport/DirectionsPreviewFixtures.swift | Package-local route states without live requests |
| LocalPlaceProvider.swift | Cancellable local search for map previews |

Change the fixture for the workflow you own. Checklist components use
`PreviewFixtures.checklist()` or `PreviewTripServices.makeChecklist(plans)`;
packing review variants use `TripPackingPreview.planner()`. These return
TripChecklistModel without constructing unrelated Trips workflows. Collection
components use `PreviewFixtures.collections()` or `PreviewTripServices.makeCollections(plans)`;
these construct TripCollectionsModel and a local library. Other Trips components
can use TripModel fixtures. Use the app fixture only for cross-feature
sheets or navigation. Give each view named same-file previews for
useful normal/error/empty/large-text states. Label any intentional live-service
preview; ContentView previews exercise the complete live app.

For Trips integration use `PreviewTripServices.makeTrips(plans)` or the existing
fixture factories. The Checklist host-navigation preview in TripEditorView covers
its parent-supplied title menu separately from component previews. Preview lookup
deliberately returns a sample stays query and preview
ordering preserves the supplied order. These are deterministic display fixtures,
not replacements for production algorithms. Override/inject controlled protocol
implementations for future workflow tests; see [Testing](Testing.md).
