import TripLocalization
import AppIntents

struct DraftTripItineraryIntent: AppIntent {
    static var title: LocalizedStringResource { "draft_itinerary_with_apple_intelligence" }
    static var description: IntentDescription {
        IntentDescription("plan_up_to24_saved_places_choosing_private_cloud")
    }
    static var supportedModes: IntentModes { .foreground }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "preferences", description: "intent_parameter_preferences", default: "") var preferences: String
    @Parameter(title: "number_of_days", description: "intent_parameter_draft_days", default: 3, inclusiveRange: (1, 5)) var days: Int
    @Parameter(title: "processing", description: "intent_parameter_processing", default: .onDevice) var processing: TripAIProcessingOption
    static var parameterSummary: some ParameterSummary {
        Summary("Draft \(\DraftTripItineraryIntent.$days as KeyPath<DraftTripItineraryIntent, Parameter<Int>>) days for \(\DraftTripItineraryIntent.$trip as KeyPath<DraftTripItineraryIntent, Parameter<SavedTripEntity>>) with \(\DraftTripItineraryIntent.$preferences as KeyPath<DraftTripItineraryIntent, Parameter<String>>)") {
            \DraftTripItineraryIntent.$processing as KeyPath<DraftTripItineraryIntent, Parameter<TripAIProcessingOption>>
        }
    }

    @MainActor func perform() async throws -> some IntentResult & ProvidesDialog {
        let preference = preferences.isEmpty ? TripText.defaultPlanningPreferences.text : preferences
        try await AppRuntime.draftTrip(tripID: trip.id, preferences: preference, days: days, processing: processing.processing)
        return .result(dialog: IntentDialog(TripText.openingTripToCreateADraftReviewItBefore.resource))
    }
}
