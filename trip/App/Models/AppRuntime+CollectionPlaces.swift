import Foundation
import TripDomain

extension AppRuntime {
    static func saveCollectionPlace(_ detailID: String, collectionID rawValue: String) async throws -> SavedTripCollectionEntity {
        guard let identity = TripCollectionIdentity(rawValue) else { throw TripCollectionIntentError.missingCollection }
        let library = try await editableCollectionLibrary()
        let place = try collectionSourcePlace(detailID, library: library)
        let (_, collection) = try Self.collection(identity, library: library)
        switch TripStopAvailability(placeID: place.id, stops: collection.stops) {
        case .alreadySaved: break
        case .full: throw TripCollectionIntentError.placesFull
        case .available:
            guard library.updateCollection(identity.collectionID, in: identity.tripID,
                    edit: { TripCollectionEditing.append(place, to: &$0) }) else { throw TripCollectionIntentError.missingCollection }
        }
        return try await persistCollection(identity, library: library)
    }

    private static func collectionSourcePlace(_ rawValue: String, library: TripLibraryModel) throws -> Place {
        guard let identity = TripDetailIdentity(rawValue), let plan = library.trip(identity.tripID),
              let stop = plan.days.lazy.flatMap(\.stops).first(where: { $0.id == identity.itemID }) else {
            throw TripCollectionIntentError.notVisit
        }
        return stop.place
    }
}
