import AppIntents

struct TripShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: OpenSavedTripIntent(), phrases: ["Open \(\OpenSavedTripIntent.$target as KeyPath<OpenSavedTripIntent, IntentParameter<SavedTripEntity>>) in \(.applicationName)"],
                    shortTitle: "open_trip", systemImageName: "suitcase.rolling")
        AppShortcut(intent: CreateTripIntent(), phrases: ["Create a trip in \(.applicationName)"],
                    shortTitle: "create_trip", systemImageName: "plus")
        AppShortcut(intent: ReadTripItineraryIntent(), phrases: ["Read my itinerary in \(.applicationName)"],
                    shortTitle: "read_itinerary", systemImageName: "list.bullet")
        AppShortcut(intent: ReadTripDayIntent(), phrases: ["What's planned today in \(.applicationName)"],
                    shortTitle: "my_trip_day", systemImageName: "calendar")
        AppShortcut(intent: DraftTripItineraryIntent(), phrases: ["Plan my saved places in \(.applicationName)"],
                    shortTitle: "draft_itinerary", systemImageName: "sparkles")
        AppShortcut(intent: StartTripDayIntent(), phrases: ["Track my trip day in \(.applicationName)"],
                    shortTitle: "track_trip_day", systemImageName: "figure.walk")
        AppShortcut(intent: VisitNextTripStopIntent(), phrases: ["Mark my next place visited in \(.applicationName)"],
                    shortTitle: "mark_visited", systemImageName: "checkmark.circle")
        AppShortcut(intent: EndTripDayIntent(), phrases: ["End day tracking in \(.applicationName)"],
                    shortTitle: "end_tracking", systemImageName: "stop.circle")
        AppShortcut(intent: OpenExploreIntent(), phrases: ["Explore places in \(.applicationName)"],
                    shortTitle: "intent_explore_places", systemImageName: "map")
        AppShortcut(intent: GetNextTripStepIntent(), phrases: ["What's next in \(.applicationName)"],
                    shortTitle: "next_trip_step", systemImageName: "arrow.right.circle")
    }
}
