import AppIntents
import TripDomain
import Foundation

struct ReadTripItineraryIntent: AppIntent {
    static var title: LocalizedStringResource { "read_trip_itinerary" }
    static var description: IntentDescription { IntentDescription("read_asaved_trip_splaces_flights_stays_reservations") }
    static var supportedModes: IntentModes { .background }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    static var parameterSummary: some ParameterSummary {
        Summary("Read the itinerary for \(\ReadTripItineraryIntent.$trip as KeyPath<ReadTripItineraryIntent, Parameter<SavedTripEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let plan = try await AppRuntime.trip(trip.id)
        let text = TripItineraryDescription.text(plan)
        return .result(value: text, dialog: IntentDialog(stringLiteral: text))
    }
}

nonisolated enum TripItineraryDescription {
    static func text(_ plan: TripPlan) -> String {
        let days = TripSurfacePlan(plan).days.map(TripSurfaceAgenda.description).joined(separator: "\n")
        return "\(plan.title)\n\(days)"
    }
}
