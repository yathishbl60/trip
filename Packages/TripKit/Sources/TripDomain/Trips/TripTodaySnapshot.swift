import Foundation

/// Saved data only. Routing estimates and automatic completion are deliberately absent.
public nonisolated struct TripTodaySnapshot: Sendable {
    public let tripID: UUID
    public let day: TripDay?
    public let items: [TripTodayItem]
    public let next: TripTodayItem?
    public let needsTimeZoneReview: Bool
    public let calendar: Calendar

    public init(trip: TripPlan, at now: Date, journey: TripJourney? = nil) {
        tripID = trip.id
        calendar = trip.calendar
        needsTimeZoneReview = trip.needsTimeZoneReview
        day = trip.days.first { trip.calendar.isDate(trip.date(for: $0), inSameDayAs: now) }
        items = day.map { TripTodayProjection.items(trip: trip, day: $0, journey: journey) } ?? []
        next = Self.next(in: items, at: now, calendar: trip.calendar)
    }

    private static func next(in items: [TripTodayItem], at now: Date, calendar: Calendar) -> TripTodayItem? {
        items.enumerated().compactMap { index, item -> (TripTodayItem, Int, Date, Int)? in
            guard let priority = item.priority(at: now, calendar: calendar) else { return nil }
            return (item, priority, item.startsAt ?? .distantFuture, index)
        }.min { ($0.1, $0.2, $0.3) < ($1.1, $1.2, $1.3) }?.0
    }
}
