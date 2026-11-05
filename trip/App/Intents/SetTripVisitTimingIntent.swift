import AppIntents
import TripLocalization

@AppIntent(.tool)
struct SetTripVisitTimingIntent {
    static var title: LocalizedStringResource { "intent_set_visit_timing" }
    static var description: IntentDescription { IntentDescription("intent_set_visit_timing_description") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "place", description: "intent_parameter_timed_visit") var place: SavedTripDetailEntity
    @Parameter(title: "intent_visit_timing", description: "intent_parameter_visit_timing") var timing: TripVisitTimingInput

    static var parameterSummary: some ParameterSummary {
        Summary("Set visit timing for \(\SetTripVisitTimingIntent.$place as KeyPath<SetTripVisitTimingIntent, Parameter<SavedTripDetailEntity>>)") {
            \SetTripVisitTimingIntent.$timing as KeyPath<SetTripVisitTimingIntent, Parameter<TripVisitTimingInput>>
        }
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripDetailEntity> & ProvidesDialog {
        let result = try await AppRuntime.setVisitTiming(timing.change, detailID: place.id)
        return .result(value: result, dialog: IntentDialog(TripText.siriTimingUpdated(result.name).resource))
    }
}
