import Foundation

public nonisolated struct TripCollectionIdentity: Hashable, Sendable {
    public let tripID: UUID
    public let collectionID: UUID
    public var rawValue: String { "\(tripID.uuidString)/\(collectionID.uuidString)" }

    public init(tripID: UUID, collectionID: UUID) {
        self.tripID = tripID
        self.collectionID = collectionID
    }

    public init?(_ rawValue: String) {
        let parts = rawValue.split(separator: "/", omittingEmptySubsequences: false)
        guard parts.count == 2, let trip = UUID(uuidString: String(parts[0])),
              let collection = UUID(uuidString: String(parts[1])) else { return nil }
        self.init(tripID: trip, collectionID: collection)
    }

    public func resolve(in plan: TripPlan) -> TripCollection? {
        guard plan.id == tripID else { return nil }
        return plan.collections.first { $0.id == collectionID }
    }
}
