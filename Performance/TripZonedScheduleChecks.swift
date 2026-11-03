import Foundation

enum TripZonedScheduleChecks {
    static func run() throws {
        try repeatedSchedule()
        try missingSchedule()
        try removedEndpoint()
    }

    private static func repeatedSchedule() throws {
        var trip = TripJourneyFixtures.plan()
        _ = trip.reviewTimeZone("America/New_York", departure: TripLocalDate(year: 2026, month: 11, day: 1))
        var day = trip.days[0]
        let date = trip.date(for: day)
        day.schedule = TripDaySchedule(startMinute: 90, endMinute: 240)
        try require(TripDayTimeline(day: day, date: date, calendar: trip.calendar) == nil, "Repeated day start guessed")
        day.schedule?.startOccurrence = .first
        let first = TripDayTimeline(day: day, date: date, calendar: trip.calendar)!
        day.schedule?.startOccurrence = .last
        let last = TripDayTimeline(day: day, date: date, calendar: trip.calendar)!
        try require(last.start.timeIntervalSince(first.start) == 3600, "Day-start occurrence ignored")
        let decoded = try JSONDecoder().decode(TripDay.self, from: JSONEncoder().encode(day))
        try require(decoded.schedule == day.schedule, "Schedule occurrence not persisted")
    }

    private static func missingSchedule() throws {
        var trip = TripJourneyFixtures.plan()
        _ = trip.reviewTimeZone("America/New_York", departure: TripLocalDate(year: 2026, month: 3, day: 8))
        trip.days[0].schedule = TripDaySchedule(startMinute: 150, endMinute: 240)
        let date = trip.date(for: trip.days[0])
        try require(TripDayTimeline(day: trip.days[0], date: date, calendar: trip.calendar) == nil, "Missing day start shifted")
        let today = TripTodaySnapshot(trip: trip, at: date.addingTimeInterval(1800))
        let visit = today.items.first { $0.item.stop != nil }!
        try require(visit.requiresTimeReview && visit.leaveBy == nil, "Invalid schedule produced leave-by")
    }

    private static func removedEndpoint() throws {
        var trip = TripJourneyFixtures.plan()
        _ = trip.reviewTimeZone("Asia/Bangkok", departure: TripLocalDate(year: 2026, month: 10, day: 16))
        let stayID = trip.events[1].id
        let arrival = trip.events[1].arrivalTime
        try require(trip.removeJourneyDay(trip.days[0].id), "Could not remove endpoint day")
        let stay = trip.events.first { $0.id == stayID }!
        try require(stay.departureTime == nil && stay.arrivalTime == arrival, "Day removal retained deleted zoned endpoint")
    }
}
