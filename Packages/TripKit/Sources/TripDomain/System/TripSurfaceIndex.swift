import Foundation

public nonisolated struct TripSurfaceIndex: Codable, Sendable {
    public let updatedAt: Date
    public let trips: [TripSurfaceSummary]

    public init(plans: [TripSurfacePlan], updatedAt: Date) {
        self.updatedAt = updatedAt
        trips = plans.map(TripSurfaceSummary.init).sorted { $0.startDate < $1.startDate }
    }
}

public nonisolated struct TripSurfaceSummary: Codable, Sendable, Identifiable {
    public let id: UUID
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let dayCount: Int
    public let stopCount: Int
    public let zoneID: String?
    public var calendar: Calendar { TripLocalDate.calendar(zoneID: zoneID ?? TimeZone.current.identifier) }

    public init(_ plan: TripSurfacePlan) {
        id = plan.id
        title = plan.title
        startDate = plan.startDate
        endDate = plan.endDate
        dayCount = plan.days.count
        stopCount = plan.days.reduce(0) { $0 + $1.stops.count }
        zoneID = plan.days.first?.zoneID
    }
}
