import TripLocalization
import AppIntents
import Foundation

struct CreateTripIntent: AppIntent {
    static var title: LocalizedStringResource { "create_trip" }
    static var description: IntentDescription { IntentDescription("create_atrip_with_aname_departure_date_and") }
    static var supportedModes: IntentModes { .foreground }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "name", description: "intent_parameter_new_trip_name") var name: String
    @Parameter(title: "departure_date", description: "intent_parameter_new_trip_departure") var departure: Date
    @Parameter(title: "number_of_days", description: "intent_parameter_new_trip_days", default: 3, inclusiveRange: (1, 30)) var dayCount: Int
    static var parameterSummary: some ParameterSummary {
        Summary("Create \(\CreateTripIntent.$name as KeyPath<CreateTripIntent, Parameter<String>>) departing \(\CreateTripIntent.$departure as KeyPath<CreateTripIntent, Parameter<Date>>) for \(\CreateTripIntent.$dayCount as KeyPath<CreateTripIntent, Parameter<Int>>) days")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripEntity> & ProvidesDialog {
        let trip = try await AppRuntime.createTrip(name: name, departure: departure, days: dayCount)
        AppRuntime.openTrip(trip.id)
        return .result(value: trip, dialog: IntentDialog(TripText.createdValue(trip.name).resource))
    }
}
