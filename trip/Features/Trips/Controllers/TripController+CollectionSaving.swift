import TripDomain
import Foundation

extension TripController {
    var collections: TripCollectionsController { TripCollectionsController(model: model.collections) }

    func save(_ place: Place, in collectionID: UUID, tripID: UUID) {
        if model.collections.save(place, in: collectionID, tripID: tripID) { dismissDestination() }
    }
}
