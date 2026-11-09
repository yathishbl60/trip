# Preview fixtures

Use the smallest local fixture that constructs the component you are changing.
Fixtures live in `trip/PreviewSupport` behind `#if DEBUG`; production code must not
reference them. A preview is a reproducible state for inspection, not evidence that
a screen has been visually verified.

## Pick a fixture

| Component | Factory or source |
| --- | --- |
| Trips workspace | `PreviewFixtures.tripPlanner()`, `emptyTripPlanner()`, `PreviewTripServices.makeTrips(plans)` |
| Checklist and packing | `PreviewFixtures.checklist()`, `PreviewTripServices.makeChecklist(plans)`, `TripPackingPreview` |
| Collections | `PreviewFixtures.collections()`, `PreviewTripServices.makeCollections(plans)` |
| Cross-feature save/navigation | `PreviewFixtures.app()` in `PreviewFixtures+App.swift` |
| Explore places and density | `PreviewFixtures.swift`, `PreviewFixtures+Density.swift`, `LocalPlaceProvider.swift` |
| Map results and saved status | `MapBrowsePreviewFixtures.loaded()`, `PlaceDetailPreviewFixtures.saved()` |
| Journey and time editing | `TripJourneyPreview`, `TripClockPreview`, `TripSchedulePreview`, `TripTodayPreview` |
| Map, ordering and day review | `TripMapPreview`, `TripStopOrderPreview`, `TripPlanningPreview` |
| Search and autocomplete | `TripPlaceSearchPreview`, `PlaceAutocompletePreview` |
| Import, exports and weather | `TripBookingPreview`, `PreviewSystemActions`, `TripWeatherPreview` |
| Language and adaptive layouts | `TripLocalizationPreview`, `TripLayoutPreview` |
| Widgets and activities | `Widgets/TripWidgetFixtures.swift`, `Widgets/TripActivityFixtures.swift` |
| Reusable directions UI | `Packages/TripKit/Sources/TripRouting/Feature/PreviewSupport/DirectionsPreviewFixtures.swift` |

Checklist and Collections factories return their focused models with a local
library; they do not construct TripModel or unrelated services. The Checklist
host-navigation preview in TripEditorView separately covers the parent title menu.
Use App fixtures only when the behavior crosses features.

## Add a useful preview

Keep named previews in the view's own Swift file. Choose states that expose the
changed behavior: normal, empty, failure, long content, large text or dark
appearance. Reuse fixtures instead of repeating production composition. Keep the
project's file/member limits when adding variants.

`PreviewTripServices` uses an isolated value store and deterministic planning,
lookup, ordering, document, weather and system-action providers. Lookup returns a
fixed stays query; ordering preserves the supplied order. These show state without
pretending to execute the real algorithms. The optional Trips live-search factory
is omitted, so editing a picker query cannot start live text search.

Native basemaps can still depend on system map availability. Label previews that
intentionally use live services: ContentView previews use complete live app
composition. Do not describe those as isolated fixtures.

## Verification

Source checks establish DEBUG boundaries and named-preview syntax. Canvas rendering,
interaction, accessibility and real service behavior are separate checks. See
[Contributing](../CONTRIBUTING.md) for commands and [Testing](Testing.md) for isolated
test fixtures; test targets should not depend on DEBUG preview data.
