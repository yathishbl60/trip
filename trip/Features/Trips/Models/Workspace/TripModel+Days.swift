import TripDomain
import Foundation

extension TripModel {
    func addDay(to tripID: UUID) {
        library.update(tripID) { trip in
            guard trip.days.count < TripLimits.days else { return false }
            trip.days.append(TripDay(number: trip.days.count + 1))
            return true
        }
    }

    func deleteDay(from tripID: UUID) {
        guard let deletedID = presentation.dayToDelete else { return }
        let removed = library.update(tripID) { $0.removeJourneyDay(deletedID) }
        if removed { presentation.dayToDelete = nil }
    }

    func setDayNotes(_ notes: String, in dayID: UUID, tripID: UUID) {
        library.updateDay(dayID, in: tripID) { day in
            day.notes = String(notes.prefix(TripLimits.noteCharacters))
            return true
        }
    }
}
