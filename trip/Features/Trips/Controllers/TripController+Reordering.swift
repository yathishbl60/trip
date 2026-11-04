import Foundation
import SwiftUI
import TripDomain

extension TripController {
    func reorderStops(_ difference: ReorderDifference<UUID, TripJourneyReorderGroupID>, in trip: TripPlan) {
        let beforeID: UUID?
        switch difference.destination.position {
        case .before(let id): beforeID = id
        case .end: beforeID = difference.destination.collectionID.followingID
        }
        let move = TripStopTransfer(sourceIDs: difference.sources,
                                   destinationDayID: difference.destination.collectionID.dayID,
                                   beforeID: beforeID, snapshot: trip)
        model.transferStops(move, tripID: trip.id)
    }

    func removeJourneyVisits(_ offsets: IndexSet, items: [TripJourneyItem], day: TripDay, trip: TripPlan) {
        model.removeJourneyVisits(offsets, items: items, day: day, trip: trip)
    }
}
