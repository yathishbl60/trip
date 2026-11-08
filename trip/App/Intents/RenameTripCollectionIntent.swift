import AppIntents
import Foundation

@AppIntent(.tool)
struct RenameTripCollectionIntent {
    static var title: LocalizedStringResource { "intent_rename_trip_collection" }
    static var description: IntentDescription { IntentDescription("intent_rename_trip_collection_description") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "collection", description: "intent_parameter_saved_collection") var collection: SavedTripCollectionEntity
    @Parameter(title: "intent_collection_name", description: "intent_parameter_collection_name") var name: String

    static var parameterSummary: some ParameterSummary {
        Summary("Rename collection \(\RenameTripCollectionIntent.$collection as KeyPath<RenameTripCollectionIntent, Parameter<SavedTripCollectionEntity>>) to \(\RenameTripCollectionIntent.$name as KeyPath<RenameTripCollectionIntent, Parameter<String>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripCollectionEntity> {
        .result(value: try await AppRuntime.renameCollection(collection.id, title: name))
    }
}
