import AppIntents
import TripLocalization

@AppIntent(.tool)
struct MoveSavedTripPlaceIntent {
    static var title: LocalizedStringResource { "intent_move_saved_visit" }
    static var description: IntentDescription { IntentDescription("intent_move_saved_visit_description") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "place", description: "intent_parameter_moving_visit") var place: SavedTripDetailEntity
    @Parameter(title: "day_number", description: "intent_parameter_destination_day", inclusiveRange: (1, 30)) var day: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Move \(\MoveSavedTripPlaceIntent.$place as KeyPath<MoveSavedTripPlaceIntent, Parameter<SavedTripDetailEntity>>) to day \(\MoveSavedTripPlaceIntent.$day as KeyPath<MoveSavedTripPlaceIntent, Parameter<Int>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripDetailEntity> & ProvidesDialog {
        let result = try await AppRuntime.moveSavedVisit(place.id, to: day)
        return .result(value: result, dialog: IntentDialog(TripText.siriMovedVisit(result.name, TripText.number(result.day)).resource))
    }
}
