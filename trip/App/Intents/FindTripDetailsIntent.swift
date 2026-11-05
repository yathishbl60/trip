import TripLocalization
import AppIntents
import Foundation
import TripDomain

struct FindTripDetailsIntent: AppIntent {
    static var title: LocalizedStringResource { "find_saved_trip_details" }
    static var description: IntentDescription { IntentDescription("find_stays_flights_reservations_places_and_times_in_your") }
    static var supportedModes: IntentModes { .foreground }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "question", default: "") var question: String
    static var parameterSummary: some ParameterSummary {
        Summary("Find details in \(\FindTripDetailsIntent.$trip as KeyPath<FindTripDetailsIntent, Parameter<SavedTripEntity>>)") {
            \FindTripDetailsIntent.$question as KeyPath<FindTripDetailsIntent, Parameter<String>>
        }
    }

    @MainActor func perform() async throws -> some IntentResult & ProvidesDialog {
        let plan = try await AppRuntime.trip(trip.id)
        AppLaunchModel.shared.open(.findTrip(plan.id, question))
        return .result(dialog: IntentDialog(TripText.openingSavedDetailsInValue(trip.name).resource))
    }
}
