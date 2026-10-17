import Foundation

public nonisolated struct TripJourney: Codable, Equatable, Sendable {
    public let tripID: UUID
    public let dayID: UUID
    public let startedAt: Date
    public let expiresAt: Date
    public var visited: [UUID] = []
    public var isActive = true

    public init(tripID: UUID, dayID: UUID, now: Date = .now) {
        self.tripID = tripID
        self.dayID = dayID
        startedAt = now
        expiresAt = now.addingTimeInterval(7.5 * 60 * 60)
    }

    public func nextStop(in day: TripSurfaceDay) -> TripSurfaceStop? {
        day.stops.first { !visited.contains($0.id) }
    }

    public mutating func reconcile(with day: TripSurfaceDay, now: Date = .now) {
        let identifiers = Set(day.stops.map(\.id))
        visited = visited.filter { identifiers.contains($0) }
        if now >= expiresAt || nextStop(in: day) == nil { isActive = false }
    }
}
