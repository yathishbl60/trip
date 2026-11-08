import AppIntents
import Foundation

@AppIntent(.tool)
struct ReadTripCollectionIntent {
    static var title: LocalizedStringResource { "intent_read_trip_collection" }
    static var description: IntentDescription { IntentDescription("intent_read_trip_collection_description") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "collection", description: "intent_parameter_saved_collection") var collection: SavedTripCollectionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Read collection \(\ReadTripCollectionIntent.$collection as KeyPath<ReadTripCollectionIntent, Parameter<SavedTripCollectionEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let result = try await AppRuntime.readCollection(collection.id)
        return .result(value: result.text, dialog: IntentDialog(stringLiteral: result.spoken))
    }
}
