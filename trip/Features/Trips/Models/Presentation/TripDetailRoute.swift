import Foundation

nonisolated struct TripDetailRoute: Hashable {
    enum Destination: Hashable {
        case map, checklist, collections, lookup, today
        case collection(UUID)
    }

    private enum Target: Hashable {
        case section(Destination), dayMap(UUID)
    }

    let tripID: UUID
    private let target: Target
    private let visitID = UUID()

    var destination: Destination {
        switch target {
        case .section(let destination): destination
        case .dayMap: .map
        }
    }

    var dayID: UUID? {
        if case .dayMap(let id) = target { id } else { nil }
    }

    init(tripID: UUID, destination: Destination) {
        self.tripID = tripID
        target = .section(destination)
    }

    init(tripID: UUID, dayID: UUID) {
        self.tripID = tripID
        target = .dayMap(dayID)
    }

    static func sameDestination(_ first: Self?, _ second: Self?) -> Bool {
        switch (first, second) {
        case (nil, nil): true
        case (let first?, let second?): first.tripID == second.tripID && first.target == second.target
        case (.some, nil), (nil, .some): false
        }
    }
}
