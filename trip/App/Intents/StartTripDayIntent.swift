import TripLocalization
import AppIntents
import TripDomain
import Foundation

struct StartTripDayIntent: AppIntent {
    static var title: LocalizedStringResource { "track_trip_day" }
    static var description: IntentDescription { IntentDescription("show_your_next_planned_place_and_visited_progress_on") }
    static var supportedModes: IntentModes { .foreground }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "day_number", description: "intent_parameter_day_number", default: 1, inclusiveRange: (1, 30)) var day: Int
    static var parameterSummary: some ParameterSummary {
        Summary("Track day \(\StartTripDayIntent.$day as KeyPath<StartTripDayIntent, Parameter<Int>>) of \(\StartTripDayIntent.$trip as KeyPath<StartTripDayIntent, Parameter<SavedTripEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ProvidesDialog {
        try await AppRuntime.startDay(tripID: trip.id, number: day)
        return .result(dialog: IntentDialog(TripText.trackingDayValueOfValue(TripText.number(day), trip.name).resource))
    }
}

struct VisitNextTripStopIntent: LiveActivityIntent {
    static var title: LocalizedStringResource { "mark_next_place_visited" }
    static var supportedModes: IntentModes { .background }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    static var parameterSummary: some ParameterSummary { Summary("Mark the next place in my tracked day visited") }

    @MainActor func perform() async throws -> some IntentResult & ProvidesDialog {
        try await TripJourneyRuntime.shared.advance()
        let id = TripJourneyRuntime.shared.journey?.visited.last
        let name = TripJourneyRuntime.shared.day?.stops.first { $0.id == id }?.name ?? TripText.place.text
        return .result(dialog: IntentDialog(TripText.markedValueVisited(name).resource))
    }
}
