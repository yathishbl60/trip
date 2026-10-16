import Foundation

public nonisolated struct TripChecklistIdentity: Hashable, Sendable {
    public let tripID: UUID
    public let itemID: UUID
    public var rawValue: String { "\(tripID.uuidString)/\(itemID.uuidString)" }

    public init(tripID: UUID, itemID: UUID) {
        self.tripID = tripID
        self.itemID = itemID
    }

    public init?(_ rawValue: String) {
        let parts = rawValue.split(separator: "/", omittingEmptySubsequences: false)
        guard parts.count == 2, let trip = UUID(uuidString: String(parts[0])),
              let item = UUID(uuidString: String(parts[1])) else { return nil }
        self.init(tripID: trip, itemID: item)
    }

    public func resolve(in plan: TripPlan) -> TripChecklistItem? {
        guard plan.id == tripID else { return nil }
        return plan.checklist.first { $0.id == itemID }
    }
}
