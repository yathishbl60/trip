import AppIntents
import TripDomain

struct OpenSavedTripIntent: OpenIntent {
    static var title: LocalizedStringResource { "open_saved_trip" }
    static var description: IntentDescription { IntentDescription("intent_open_saved_trip_description") }
    static var supportedModes: IntentModes { .foreground }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var target: SavedTripEntity
    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\OpenSavedTripIntent.$target as KeyPath<OpenSavedTripIntent, Parameter<SavedTripEntity>>)")
    }

    init() {}
    init(trip: SavedTripEntity) { target = trip }

    @MainActor func perform() async throws -> some IntentResult {
        let trip = try await AppRuntime.trip(target.id)
        AppRuntime.openTrip(trip.id)
        return .result()
    }
}
