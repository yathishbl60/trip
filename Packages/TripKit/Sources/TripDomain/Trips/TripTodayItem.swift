import Foundation

public nonisolated struct TripTodayItem: Identifiable, Sendable {
    public let item: TripJourneyItem
    public let startsAt: Date?
    public let endsAt: Date?
    public let leaveBy: Date?
    public let zoneID: String
    public let requiresTimeReview: Bool
    public let isEstimate: Bool
    public let isVisited: Bool
    public var id: UUID { item.id }
    public var title: String {
        switch item {
        case .visit(let stop): stop.place.name
        case .event(let event): event.title
        }
    }
    public var symbol: String {
        switch item {
        case .visit(let stop): stop.place.category.symbol
        case .event(let event): event.kind.symbol
        }
    }

    func priority(at now: Date, calendar: Calendar) -> Int? {
        guard !isVisited else { return nil }
        if case .event(let event) = item {
            if let endsAt, endsAt < now { return nil }
            if event.kind == .stay, let startsAt, startsAt < now,
               endsAt.map({ calendar.isDate($0, inSameDayAs: now) }) != true { return nil }
        }
        if requiresTimeReview { return 2 }
        guard let startsAt else { return 3 }
        return startsAt >= now ? 0 : (endsAt.map { $0 >= now } == true ? 1 : 4)
    }
}
