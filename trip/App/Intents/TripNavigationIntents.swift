import AppIntents

struct OpenExploreIntent: AppIntent {
    static var title: LocalizedStringResource { "intent_explore_places" }
    static var description: IntentDescription { IntentDescription("open_the_map_to_find_places_stays_and_activities") }
    static var supportedModes: IntentModes { .foreground }
    static var parameterSummary: some ParameterSummary { Summary("Explore places") }

    @MainActor func perform() async throws -> some IntentResult {
        AppLaunchModel.shared.open(.explore)
        return .result()
    }
}

struct OpenTripsIntent: AppIntent {
    static var title: LocalizedStringResource { "intent_open_my_trips" }
    static var description: IntentDescription { IntentDescription("open_your_saved_trips_and_itineraries") }
    static var supportedModes: IntentModes { .foreground }
    static var parameterSummary: some ParameterSummary { Summary("Open my trips") }

    @MainActor func perform() async throws -> some IntentResult {
        AppLaunchModel.shared.open(.trips)
        return .result()
    }
}

struct NewTripIntent: AppIntent {
    static var title: LocalizedStringResource { "start_anew_trip" }
    static var description: IntentDescription { IntentDescription("open_trip_to_create_atrip") }
    static var supportedModes: IntentModes { .foreground }
    static var parameterSummary: some ParameterSummary { Summary("Start a new trip") }

    @MainActor func perform() async throws -> some IntentResult {
        AppLaunchModel.shared.open(.newTrip)
        return .result()
    }
}
