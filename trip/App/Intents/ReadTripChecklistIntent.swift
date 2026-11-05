import AppIntents
import SwiftUI
import Foundation
import TripDomain

struct ReadTripChecklistIntent: AppIntent {
    static var title: LocalizedStringResource { "read_trip_checklist" }
    static var description: IntentDescription { IntentDescription("read_remaining_packing_and_preparation_items_with_an_interactive") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    static var parameterSummary: some ParameterSummary {
        Summary("Read the checklist for \(\ReadTripChecklistIntent.$trip as KeyPath<ReadTripChecklistIntent, Parameter<SavedTripEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog & ShowsSnippetIntent {
        let plan = try await AppRuntime.trip(trip.id)
        let brief = TripChecklistBriefing(plan)
        return .result(value: brief.text, dialog: IntentDialog(stringLiteral: brief.spokenSummary),
                       snippetIntent: TripChecklistSnippetIntent(tripID: plan.id))
    }
}

struct TripChecklistSnippetIntent: SnippetIntent {
    static var title: LocalizedStringResource { "trip_checklist" }
    static var isDiscoverable: Bool { false }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip_identifier") var tripIdentifier: String

    init() {}
    init(tripID: UUID) { tripIdentifier = tripID.uuidString }

    @MainActor func perform() async throws -> some IntentResult & ShowsSnippetView {
        guard let id = UUID(uuidString: tripIdentifier) else { throw TripIntentError.missingTrip }
        let plan = try await AppRuntime.trip(id)
        return .result(view: TripChecklistSnippetView(plan: plan, briefing: TripChecklistBriefing(plan)))
    }
}
