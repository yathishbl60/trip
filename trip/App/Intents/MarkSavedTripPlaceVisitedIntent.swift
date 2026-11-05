import AppIntents
import TripLocalization

@AppIntent(.tool)
struct MarkSavedTripPlaceVisitedIntent {
    static var title: LocalizedStringResource { "intent_mark_saved_visit" }
    static var description: IntentDescription { IntentDescription("intent_mark_saved_visit_description") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "place", description: "intent_parameter_tracked_visit") var place: SavedTripDetailEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Mark \(\MarkSavedTripPlaceVisitedIntent.$place as KeyPath<MarkSavedTripPlaceVisitedIntent, Parameter<SavedTripDetailEntity>>) visited")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripDetailEntity> & ProvidesDialog {
        let result = try await AppRuntime.markSavedVisit(place.id)
        return .result(value: result, dialog: IntentDialog(TripText.markedValueVisited(result.name).resource))
    }
}
