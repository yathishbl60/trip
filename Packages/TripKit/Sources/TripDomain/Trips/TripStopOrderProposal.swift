import Foundation

/// A local geographic suggestion, not a road route or travel-time estimate.
public nonisolated struct TripStopOrderProposal: Sendable {
    public let dayID: UUID
    public let original: [TripStopOrderPoint]
    public let suggestedIDs: [UUID]
    public let originalDistance: Double
    public let suggestedDistance: Double

    public init(day: TripDay, suggestedIDs: [UUID], originalDistance: Double, suggestedDistance: Double) {
        dayID = day.id
        original = day.stops.map(TripStopOrderPoint.init)
        self.suggestedIDs = suggestedIDs
        self.originalDistance = originalDistance
        self.suggestedDistance = suggestedDistance
    }

    public var hasImprovement: Bool {
        originalDistance - suggestedDistance >= max(25, originalDistance * 0.01)
    }

    public func matches(_ day: TripDay) -> Bool {
        day.id == dayID && day.stops.map(TripStopOrderPoint.init) == original
    }

    public func apply(to day: inout TripDay) -> Bool {
        guard hasImprovement, matches(day), suggestedIDs.count == day.stops.count,
              Set(suggestedIDs) == Set(original.map(\.id)),
              suggestedIDs.first == day.stops.first?.id else { return false }
        let stops = Dictionary(day.stops.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        day.stops = suggestedIDs.compactMap { stops[$0] }
        return true
    }
}

public nonisolated struct TripStopOrderPoint: Equatable, Sendable {
    public let id: UUID
    public let coordinate: Coordinate

    public init(_ stop: TripStop) {
        id = stop.id
        coordinate = stop.place.coordinate
    }
}
