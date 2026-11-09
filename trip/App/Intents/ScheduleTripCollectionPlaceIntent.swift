import AppIntents
import TripLocalization

@AppIntent(.tool)
struct ScheduleTripCollectionPlaceIntent {
    static var title: LocalizedStringResource { "intent_schedule_collection_place" }
    static var description: IntentDescription { IntentDescription("intent_schedule_collection_place_description") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "place", description: "intent_parameter_collection_place") var place: SavedTripCollectionPlaceEntity
    @Parameter(title: "day_number", description: "intent_parameter_destination_day", inclusiveRange: (1, 30)) var day: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Schedule \(\ScheduleTripCollectionPlaceIntent.$place as KeyPath<ScheduleTripCollectionPlaceIntent, Parameter<SavedTripCollectionPlaceEntity>>) on day \(\ScheduleTripCollectionPlaceIntent.$day as KeyPath<ScheduleTripCollectionPlaceIntent, Parameter<Int>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripDetailEntity> & ProvidesDialog {
        let result = try await AppRuntime.scheduleCollectionPlace(place.id, on: day)
        return .result(value: result, dialog: IntentDialog(TripText.collectionPlaceScheduled(result.name, TripText.number(result.day)).resource))
    }
}
