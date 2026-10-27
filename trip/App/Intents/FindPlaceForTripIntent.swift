import TripLocalization
import AppIntents
import Foundation

struct FindPlaceForTripIntent: AppIntent {
    static var title: LocalizedStringResource { "find_aplace_for_my_trip" }
    static var description: IntentDescription {
        IntentDescription("search_aplace_name_or_address_in_trip_then")
    }
    static var supportedModes: IntentModes { .foreground }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "place_or_address") var text: String
    @Parameter(title: "trip") var trip: SavedTripEntity
    @Parameter(title: "day_number", inclusiveRange: (1, 30)) var day: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Find \(\FindPlaceForTripIntent.$text as KeyPath<FindPlaceForTripIntent, Parameter<String>>) for \(\FindPlaceForTripIntent.$trip as KeyPath<FindPlaceForTripIntent, Parameter<SavedTripEntity>>)") {
            \FindPlaceForTripIntent.$day as KeyPath<FindPlaceForTripIntent, Parameter<Int>>
        }
    }

    @MainActor func perform() async throws -> some IntentResult & ProvidesDialog {
        let title = try await AppRuntime.searchPlace(text: text, tripID: trip.id, dayNumber: day)
        return .result(dialog: IntentDialog(TripText.openingPlaceSearchForDayValueOfValueChoose(TripText.number(day), title).resource))
    }
}
