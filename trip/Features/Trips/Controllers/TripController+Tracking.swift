import TripDomain
import Foundation

extension TripController {
    func startTracking(dayID: UUID, tripID: UUID) {
        guard let trip = model.library.trip(tripID) else { return }
        model.tracking.start(trip, dayID: dayID)
    }

    func visitNextStop() { model.tracking.visit() }
    func undoVisit() { model.tracking.undo() }
    func endTracking() { model.tracking.end() }
}
