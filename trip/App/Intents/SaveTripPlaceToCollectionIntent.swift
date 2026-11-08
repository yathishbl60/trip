import AppIntents
import Foundation

@AppIntent(.tool)
struct SaveTripPlaceToCollectionIntent {
    static var title: LocalizedStringResource { "intent_save_trip_place_to_collection" }
    static var description: IntentDescription { IntentDescription("intent_save_trip_place_to_collection_description") }
    static var supportedModes: IntentModes { .background }
    static var allowedExecutionTargets: IntentExecutionTargets { .main }
    static var authenticationPolicy: IntentAuthenticationPolicy { .requiresAuthentication }
    @Parameter(title: "place", description: "intent_parameter_collection_source_visit") var place: SavedTripDetailEntity
    @Parameter(title: "collection", description: "intent_parameter_saved_collection") var collection: SavedTripCollectionEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Save \(\SaveTripPlaceToCollectionIntent.$place as KeyPath<SaveTripPlaceToCollectionIntent, Parameter<SavedTripDetailEntity>>) to collection \(\SaveTripPlaceToCollectionIntent.$collection as KeyPath<SaveTripPlaceToCollectionIntent, Parameter<SavedTripCollectionEntity>>)")
    }

    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<SavedTripCollectionEntity> {
        .result(value: try await AppRuntime.saveCollectionPlace(place.id, collectionID: collection.id))
    }
}
