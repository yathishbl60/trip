import Foundation

public nonisolated struct TripCollectionPlaceIdentity: Hashable, Sendable {
    public let collection: TripCollectionIdentity
    public let stopID: UUID
    public var rawValue: String { "\(collection.rawValue)/\(stopID.uuidString)" }

    public init(tripID: UUID, collectionID: UUID, stopID: UUID) {
        collection = TripCollectionIdentity(tripID: tripID, collectionID: collectionID)
        self.stopID = stopID
    }

    public init?(_ rawValue: String) {
        let parts = rawValue.split(separator: "/", omittingEmptySubsequences: false)
        guard parts.count == 3, let trip = UUID(uuidString: String(parts[0])),
              let collection = UUID(uuidString: String(parts[1])), let stop = UUID(uuidString: String(parts[2])) else { return nil }
        self.init(tripID: trip, collectionID: collection, stopID: stop)
    }

    public func resolve(in plan: TripPlan) -> TripStop? {
        collection.resolve(in: plan)?.stops.first { $0.id == stopID }
    }
}
