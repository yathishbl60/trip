import AppIntents
import Foundation
import TripDomain

struct AskTripQuestionIntent: AppIntent {
    static var title: LocalizedStringResource { "intent_ask_saved_trip" }
    static var description: IntentDescription { IntentDescription("intent_ask_saved_trip_description") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip") var trip: SavedTripEntity
    @Parameter(title: "question") var question: String

    static var parameterSummary: some ParameterSummary {
        Summary("Ask \(\AskTripQuestionIntent.$question as KeyPath<AskTripQuestionIntent, Parameter<String>>) about \(\AskTripQuestionIntent.$trip as KeyPath<AskTripQuestionIntent, Parameter<SavedTripEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<[SavedTripDetailEntity]> & ProvidesDialog & ShowsSnippetIntent {
        let answer = try await AppRuntime.answerQuestion(question, tripID: trip.id)
        let entities = answer.results.map { SavedTripDetailEntity($0, plan: answer.plan) }
        return .result(value: entities, dialog: IntentDialog(stringLiteral: answer.summary),
                       snippetIntent: TripAnswerSnippetIntent(answer: answer))
    }
}
