import Foundation
import TripDomain

/// Fixed arrivals and bookings stay outside the draggable collections.
nonisolated struct TripJourneyReorderGroup: Identifiable {
    let id: TripJourneyReorderGroupID
    let items: [TripJourneyItem]
    let anchor: TripJourneyItem?

    static func groups(_ items: [TripJourneyItem], dayID: UUID) -> [Self] {
        var groups: [Self] = []
        var movable: [TripJourneyItem] = []
        for item in items {
            if let stop = item.stop, stop.timing.arrivalMinute == nil { movable.append(item) }
            else {
                groups.append(Self(id: .init(dayID: dayID, followingID: item.id), items: movable, anchor: item))
                movable = []
            }
        }
        groups.append(Self(id: .init(dayID: dayID, followingID: nil), items: movable, anchor: nil))
        return groups
    }
}

nonisolated struct TripJourneyReorderGroupID: Hashable, Sendable {
    let dayID: UUID
    let followingID: UUID?
}
