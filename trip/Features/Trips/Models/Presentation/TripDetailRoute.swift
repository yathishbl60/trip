import Foundation

nonisolated struct TripDetailRoute: Hashable {
    enum Destination: Hashable {
        case map, checklist, collections, lookup, today
    }

    let tripID: UUID
    let destination: Destination
    let dayID: UUID?

    init(tripID: UUID, destination: Destination, dayID: UUID? = nil) {
        self.tripID = tripID
        self.destination = destination
        self.dayID = dayID
    }
}
