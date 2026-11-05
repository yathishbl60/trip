import AppIntents
import Foundation
import TripDomain

struct GetNextTripStepIntent: AppIntent {
    static var title: LocalizedStringResource { "get_what_snext_in_my_trip" }
    static var description: IntentDescription {
        IntentDescription("get_the_next_unvisited_place_while_tracking_or_today")
    }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity?
    static var parameterSummary: some ParameterSummary {
        Summary("Get what's next in my trip") {
            \GetNextTripStepIntent.$trip as KeyPath<GetNextTripStepIntent, Parameter<SavedTripEntity?>>
        }
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<[SavedTripDetailEntity]> & ProvidesDialog & ShowsSnippetIntent {
        let next = try await AppRuntime.nextStep(tripID: trip?.id)
        let results = next.result.map { [SavedTripDetailEntity($0, plan: next.plan)] } ?? []
        return .result(value: results, dialog: IntentDialog(stringLiteral: next.summary),
                       snippetIntent: TripNextStepSnippetIntent(tripID: next.plan.id))
    }
}
