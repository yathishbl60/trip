import TripLocalization
import TripDomain
import Foundation

extension TripModel {
    func save(_ place: Place, in collectionID: UUID, tripID: UUID) -> Bool {
        guard let collection = library.trip(tripID)?.collections.first(where: { $0.id == collectionID }),
              canAdd(place, to: collection.stops, container: .collection) else { return false }
        let saved = library.updateCollection(collectionID, in: tripID) { collection in
            collection.stops.append(TripStop(place: place))
            return true
        }
        guard saved else { return false }
        presentation.notice = nil
        feedback.show(TripText.addedToValue(collection.title).text)
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
}
