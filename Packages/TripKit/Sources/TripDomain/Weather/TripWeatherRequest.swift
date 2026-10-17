import Foundation

/// Only saved, resolvable visit times become forecast requests. Untimed visits are never assigned a guessed hour.
public nonisolated struct TripWeatherRequest: Sendable, Equatable {
    public static let visitLimit = 8
    public let tripID: UUID
    public let dayID: UUID
    public let title: String
    public let timeZoneID: String
    public let visits: [TripWeatherTarget]
    public let omittedCount: Int
    public let needsTimeReview: Bool

    public init(trip: TripPlan, day: TripDay) {
        tripID = trip.id
        dayID = day.id
        title = day.title
        timeZoneID = trip.calendar.timeZone.identifier
        needsTimeReview = trip.needsTimeZoneReview
        let timeline = TripDayTimeline(day: day, date: trip.date(for: day), calendar: trip.calendar)
        let targets = day.stops.compactMap { Self.target($0, day: day, trip: trip, timeline: timeline) }
        visits = Array(targets.prefix(Self.visitLimit))
        omittedCount = day.stops.count - visits.count
    }

    private static func target(_ stop: TripStop, day: TripDay, trip: TripPlan,
                               timeline: TripDayTimeline?) -> TripWeatherTarget? {
        guard !trip.needsTimeZoneReview, stop.place.coordinate.isValid else { return nil }
        let fixed = stop.timing.arrivalClock(on: trip.date(for: day), calendar: trip.calendar)
        guard fixed?.issue == nil, timeline?[stop.id]?.arrivalIssue == nil,
              let arrival = timeline?[stop.id]?.arrival ?? fixed?.instant else { return nil }
        return TripWeatherTarget(id: stop.id, name: stop.place.name, coordinate: stop.place.coordinate, arrival: arrival)
    }
}

public nonisolated struct TripWeatherTarget: Identifiable, Sendable, Equatable {
    public let id: UUID
    public let name: String
    public let coordinate: Coordinate
    public let arrival: Date

    public init(id: UUID, name: String, coordinate: Coordinate, arrival: Date) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.arrival = arrival
    }
}
