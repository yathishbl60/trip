import Foundation

nonisolated struct TripDetailRoute: Hashable {
    enum Destination: Hashable {
        case map, checklist, collections, lookup, today
    }

    let tripID: UUID
    let destination: Destination
}
