import Foundation

public nonisolated struct TripDetailIdentity: Hashable, Sendable {
    public let tripID: UUID
    public let itemID: UUID
    public var rawValue: String { "\(tripID.uuidString)/\(itemID.uuidString)" }

    public init(tripID: UUID, itemID: UUID) {
        self.tripID = tripID
        self.itemID = itemID
    }

    public init?(_ value: String) {
        let parts = value.split(separator: "/", omittingEmptySubsequences: false)
        guard parts.count == 2, let tripID = UUID(uuidString: String(parts[0])),
              let itemID = UUID(uuidString: String(parts[1])) else { return nil }
        self.init(tripID: tripID, itemID: itemID)
    }

    public func resolve(in plan: TripSurfacePlan) -> TripDetailResult? {
        guard tripID == plan.id else { return nil }
        return TripDetailQuery(itemID: itemID).results(in: plan).first
    }
}
