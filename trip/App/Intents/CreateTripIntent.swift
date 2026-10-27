import TripLocalization
import AppIntents
import Foundation

struct CreateTripIntent: AppIntent {
    static var title: LocalizedStringResource { "create_trip" }
    static var description: IntentDescription { IntentDescription("create_atrip_with_aname_departure_date_and") }
    static var supportedModes: IntentModes { .foreground }
    @Parameter(title: "name") var name: String
    @Parameter(title: "departure_date") var departure: Date
    @Parameter(title: "number_of_days", default: 3, inclusiveRange: (1, 30)) var dayCount: Int
    static var parameterSummary: some ParameterSummary {
        Summary("Create \(\CreateTripIntent.$name as KeyPath<CreateTripIntent, Parameter<String>>) departing \(\CreateTripIntent.$departure as KeyPath<CreateTripIntent, Parameter<Date>>) for \(\CreateTripIntent.$dayCount as KeyPath<CreateTripIntent, Parameter<Int>>) days")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripEntity> & ProvidesDialog {
        let trip = try await AppRuntime.createTrip(name: name, departure: departure, days: dayCount)
        AppRuntime.openTrip(trip.id)
        return .result(value: trip, dialog: IntentDialog(TripText.createdValue(trip.name).resource))
    }
}
