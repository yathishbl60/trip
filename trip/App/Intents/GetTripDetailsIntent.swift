import TripLocalization
import AppIntents
import Foundation
import TripDomain

enum TripDetailFilter: String, AppEnum {
    case all, stays, travel, reservations, places, freeTime, untimed
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "trip_detail_filter") }
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [.all: DisplayRepresentation(title: "whole_itinerary"), .stays: DisplayRepresentation(title: "stays"), .travel: DisplayRepresentation(title: "flights_and_trains"), .reservations: DisplayRepresentation(title: "reservations"),
         .places: DisplayRepresentation(title: "places"), .freeTime: DisplayRepresentation(title: "free_time"), .untimed: DisplayRepresentation(title: "times_to_confirm")]
    }
    var category: TripDetailCategory { TripDetailCategory(rawValue: rawValue) ?? .all }
}

struct GetTripDetailsIntent: AppIntent {
    static var title: LocalizedStringResource { "get_saved_trip_details" }
    static var description: IntentDescription { IntentDescription("return_saved_itinerary_records_for_use_in_shortcuts_zero") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "filter", default: .all) var filter: TripDetailFilter
    @Parameter(title: "day_number0_for_all", default: 0, inclusiveRange: (0, 30)) var day: Int
    @Parameter(title: "name_or_location", default: "") var search: String
    static var parameterSummary: some ParameterSummary {
        Summary("Get details from \(\GetTripDetailsIntent.$trip as KeyPath<GetTripDetailsIntent, Parameter<SavedTripEntity>>)") {
            \GetTripDetailsIntent.$filter as KeyPath<GetTripDetailsIntent, Parameter<TripDetailFilter>>
            \GetTripDetailsIntent.$day as KeyPath<GetTripDetailsIntent, Parameter<Int>>
            \GetTripDetailsIntent.$search as KeyPath<GetTripDetailsIntent, Parameter<String>>
        }
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<[SavedTripDetailEntity]> & ProvidesDialog {
        let source = try await AppRuntime.trip(trip.id)
        let plan = TripSurfacePlan(source)
        guard day == 0 || plan.days.contains(where: { $0.number == day }) else { throw TripIntentError.missingDay }
        let query = TripDetailQuery(category: filter.category, dayNumber: day == 0 ? nil : day, searchText: search)
        let results = query.results(in: plan).map { SavedTripDetailEntity($0, plan: plan) }
        return .result(value: results, dialog: IntentDialog(TripText.foundValueSavedDetailsInValue(TripText.number(results.count), source.title).resource))
    }
}
