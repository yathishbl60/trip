import TripLocalization
import TripDomain
import Foundation

extension TripModel {
    func add(_ place: Place, to tripID: UUID, dayID: UUID) -> Bool {
        guard let trip = library.trip(tripID), let day = trip.days.first(where: { $0.id == dayID }),
              canAdd(place, to: day.stops, container: .day) else { return false }
        let saved = library.updateDay(dayID, in: tripID) { day in
            day.stops.append(TripStop(place: place))
            return true
        }
        guard saved else { return false }
        presentation.notice = nil
        feedback.show(TripText.addedToValueValue(trip.title, day.title).text)
        return true
    }

    func removeStops(_ offsets: IndexSet, from snapshot: TripDay, tripID: UUID) {
        guard let edit = IdentifiedListEdit.removing(offsets, from: snapshot.stops.map(\.id)) else { return }
        library.updateDay(snapshot.id, in: tripID) { edit.apply(to: &$0.stops) }
    }

    func moveStops(_ offsets: IndexSet, to destination: Int, in snapshot: TripDay, tripID: UUID) {
        guard let edit = IdentifiedListEdit.moving(offsets, to: destination, in: snapshot.stops.map(\.id)) else { return }
        library.updateDay(snapshot.id, in: tripID) { edit.apply(to: &$0.stops) }
    }

    func setStopNotes(_ notes: String, stopID: UUID, dayID: UUID, tripID: UUID) {
        library.updateDay(dayID, in: tripID) { day in
            guard let index = day.stops.firstIndex(where: { $0.id == stopID }) else { return false }
            day.stops[index].notes = String(notes.prefix(TripLimits.noteCharacters))
            return true
        }
    }

    func canAdd(_ place: Place, to stops: [TripStop], container: TripStopDestination) -> Bool {
        switch TripStopAvailability(placeID: place.id, stops: stops) {
        case .available: return true
        case .alreadySaved: presentation.notice = container.duplicateMessage
        case .full: presentation.notice = container.capacityMessage
        }
        return false
    }
}
