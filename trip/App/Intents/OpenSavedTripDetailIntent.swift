import AppIntents
import TripDomain

struct OpenSavedTripDetailIntent: OpenIntent {
    static var title: LocalizedStringResource { "open_saved_trip_detail" }
    static var description: IntentDescription { IntentDescription("intent_open_saved_detail_description") }
    static var supportedModes: IntentModes { .foreground }
    @Parameter(title: "detail", description: "intent_parameter_saved_detail") var target: SavedTripDetailEntity
    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\OpenSavedTripDetailIntent.$target as KeyPath<OpenSavedTripDetailIntent, Parameter<SavedTripDetailEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult {
        guard let identity = TripDetailIdentity(target.id) else { throw TripIntentError.missingTrip }
        try await AppRuntime.openDetail(identity)
        return .result()
    }
}
