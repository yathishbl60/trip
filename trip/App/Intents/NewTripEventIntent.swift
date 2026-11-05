import AppIntents
import Foundation
import TripDomain
import TripLocalization

@AppIntent(.tool)
struct NewTripEventIntent {
    static var title: LocalizedStringResource { "intent_new_trip_event" }
    static var description: IntentDescription { IntentDescription("intent_new_trip_event_description") }
    static var supportedModes: IntentModes { .foreground }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "day_number", description: "intent_parameter_day_number", inclusiveRange: (1, 30)) var day: Int
    @Parameter(title: "intent_new_event_kind", description: "intent_parameter_new_event_kind") var kind: TripNewEventKind
    @Parameter(title: "title", description: "intent_parameter_new_event_title", default: "") var title: String

    static var parameterSummary: some ParameterSummary {
        Summary("Prepare \(\NewTripEventIntent.$kind as KeyPath<NewTripEventIntent, Parameter<TripNewEventKind>>) for day \(\NewTripEventIntent.$day as KeyPath<NewTripEventIntent, Parameter<Int>>) of \(\NewTripEventIntent.$trip as KeyPath<NewTripEventIntent, Parameter<SavedTripEntity>>)") {
            \NewTripEventIntent.$title as KeyPath<NewTripEventIntent, Parameter<String>>
        }
    }

    @MainActor func perform() async throws -> some IntentResult & ProvidesDialog {
        let plan = try await AppRuntime.trip(trip.id)
        try Task.checkCancellation()
        guard let day = plan.days.first(where: { $0.number == day }) else { throw TripIntentError.missingDay }
        guard AppRuntime.activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        let request = try TripNewEventRequest(trip: plan, dayID: day.id, kind: kind.kind, title: title)
        AppLaunchModel.shared.open(.newEvent(request))
        return .result(dialog: IntentDialog(TripText.newEventOpeningReview.resource))
    }
}
