import Foundation
import TripDomain

extension AppRuntime {
    static func createCollection(_ text: String, tripID: UUID) async throws -> SavedTripCollectionEntity {
        guard let title = TripCollectionEditing.title(text) else { throw TripCollectionIntentError.invalidTitle }
        let library = try await editableCollectionLibrary()
        guard let plan = library.trip(tripID) else { throw TripIntentError.missingTrip }
        let matches = plan.collections.filter { TripCollectionEditing.key($0.title) == TripCollectionEditing.key(title) }
        guard matches.count < 2 else { throw TripCollectionIntentError.ambiguousName }
        if let existing = matches.first {
            return try await persistCollection(TripCollectionIdentity(tripID: tripID, collectionID: existing.id), library: library)
        }
        guard plan.collections.count < TripLimits.collections else { throw TripCollectionIntentError.full }
        var collectionID: UUID?
        let saved = library.update(tripID) { plan in
            collectionID = TripCollectionEditing.create(title, in: &plan)
            return collectionID != nil
        }
        guard saved, let collectionID else { throw TripIntentError.missingTrip }
        return try await persistCollection(TripCollectionIdentity(tripID: tripID, collectionID: collectionID), library: library)
    }

    static func renameCollection(_ rawValue: String, title text: String) async throws -> SavedTripCollectionEntity {
        guard let identity = TripCollectionIdentity(rawValue) else { throw TripCollectionIntentError.missingCollection }
        guard let title = TripCollectionEditing.title(text) else { throw TripCollectionIntentError.invalidTitle }
        let library = try await editableCollectionLibrary()
        let (_, collection) = try Self.collection(identity, library: library)
        if collection.title != title {
            guard library.update(identity.tripID, edit: { TripCollectionEditing.rename(identity.collectionID, to: title, in: &$0) }) else {
                throw TripCollectionIntentError.missingCollection
            }
        }
        return try await persistCollection(identity, library: library)
    }
}
