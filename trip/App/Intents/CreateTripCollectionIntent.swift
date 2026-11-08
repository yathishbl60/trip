import AppIntents
import Foundation

@AppIntent(.tool)
struct CreateTripCollectionIntent {
    static var title: LocalizedStringResource { "intent_create_trip_collection" }
    static var description: IntentDescription { IntentDescription("intent_create_trip_collection_description") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "trip", description: "intent_parameter_saved_trip") var trip: SavedTripEntity
    @Parameter(title: "intent_collection_name", description: "intent_parameter_collection_name") var name: String

    static var parameterSummary: some ParameterSummary {
        Summary("Create collection \(\CreateTripCollectionIntent.$name as KeyPath<CreateTripCollectionIntent, Parameter<String>>) in \(\CreateTripCollectionIntent.$trip as KeyPath<CreateTripCollectionIntent, Parameter<SavedTripEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripCollectionEntity> {
        .result(value: try await AppRuntime.createCollection(name, tripID: trip.id))
    }
}
