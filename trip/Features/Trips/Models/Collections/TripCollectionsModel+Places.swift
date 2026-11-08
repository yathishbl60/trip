import TripLocalization
import TripDomain
import Foundation

extension TripCollectionsModel {
    func save(_ place: Place, in collectionID: UUID, tripID: UUID) -> Bool {
        guard let collection = library.trip(tripID)?.collections.first(where: { $0.id == collectionID }),
              canAdd(place, to: collection.stops) else { return false }
        let saved = library.updateCollection(collectionID, in: tripID) { collection in
            collection.stops.append(TripStop(place: place))
            return true
        }
        guard saved else { return false }
        showNotice(nil)
        environment.showFeedback(TripText.addedToValue(collection.title).text)
        return true
    }

    func removeCollectionStops(_ offsets: IndexSet, from snapshot: TripCollection, tripID: UUID) {
        guard let edit = IdentifiedListEdit.removing(offsets, from: snapshot.stops.map(\.id)) else { return }
        library.updateCollection(snapshot.id, in: tripID) { edit.apply(to: &$0.stops) }
    }

    func moveCollectionStops(_ offsets: IndexSet, to destination: Int,
                             in snapshot: TripCollection, tripID: UUID) {
        guard let edit = IdentifiedListEdit.moving(offsets, to: destination, in: snapshot.stops.map(\.id)) else { return }
        library.updateCollection(snapshot.id, in: tripID) { edit.apply(to: &$0.stops) }
    }

    private func canAdd(_ place: Place, to stops: [TripStop]) -> Bool {
        switch TripStopAvailability(placeID: place.id, stops: stops) {
        case .available: return true
        case .alreadySaved: showNotice(TripStopDestination.collection.duplicateMessage)
        case .full: showNotice(TripStopDestination.collection.capacityMessage)
        }
        return false
    }
}
