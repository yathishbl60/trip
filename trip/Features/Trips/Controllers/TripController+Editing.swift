import TripDomain
import SwiftUI

extension TripController {
    func dayNotes(_ dayID: UUID, tripID: UUID) -> Binding<String> {
        Binding(get: { model.library.trip(tripID)?.days.first(where: { $0.id == dayID })?.notes ?? "" },
                set: { model.setDayNotes($0, in: dayID, tripID: tripID) })
    }

    func stopNotes(_ stopID: UUID, dayID: UUID, tripID: UUID) -> Binding<String> {
        Binding(get: { model.library.trip(tripID)?.days.first(where: { $0.id == dayID })?
            .stops.first(where: { $0.id == stopID })?.notes ?? "" },
                set: { model.setStopNotes($0, stopID: stopID, dayID: dayID, tripID: tripID) })
    }

    func removeStops(_ offsets: IndexSet, from day: TripDay, tripID: UUID) {
        model.removeStops(offsets, from: day, tripID: tripID)
    }

    func moveStops(_ offsets: IndexSet, to destination: Int, in day: TripDay, tripID: UUID) {
        model.moveStops(offsets, to: destination, in: day, tripID: tripID)
    }
}
