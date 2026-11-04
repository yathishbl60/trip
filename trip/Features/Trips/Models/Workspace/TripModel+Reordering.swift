import Foundation
import TripDomain
import TripLocalization

extension TripModel {
    func canReorderStops(in tripID: UUID) -> Bool {
        !tracking.isBusy && !(tracking.runtime?.journey?.tripID == tripID && tracking.runtime?.journey?.isActive == true)
    }

    func transferStops(_ transfer: TripStopTransfer, tripID: UUID) {
        guard canReorderStops(in: tripID) else { return }
        guard library.update(tripID, edit: { transfer.apply(to: &$0) }) else {
            presentation.notice = TripText.stopMoveUnavailable.text
            return
        }
        presentation.notice = nil
        feedback.show(TripText.updatedStopOrder.text)
    }

    func hasVisited(_ stopID: UUID, dayID: UUID, tripID: UUID) -> Bool {
        guard let journey = tracking.runtime?.journey,
              journey.tripID == tripID, journey.dayID == dayID else { return false }
        return journey.visited.contains(stopID)
    }

    func removeJourneyVisits(_ offsets: IndexSet, items: [TripJourneyItem], day: TripDay, trip: TripPlan) {
        guard offsets.allSatisfy(items.indices.contains) else { return }
        let ids = Set(offsets.compactMap { items[$0].stop?.id })
        let stops = IndexSet(day.stops.indices.filter { ids.contains(day.stops[$0].id) })
        removeStops(stops, from: day, tripID: trip.id)
    }
}
