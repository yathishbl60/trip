import Foundation

enum TripTimeZonePersistenceChecks {
    static func run() throws {
        try legacyReview()
        try stableDates()
        try projectedClock()
    }

    private static func legacyReview() throws {
        var original = TripJourneyFixtures.plan()
        original.startDate = TripTimeZoneChecks.clock(2026, 10, 16, 720, "Etc/UTC").instant!
        var object = try JSONSerialization.jsonObject(with: JSONEncoder().encode(original)) as! [String: Any]
        object.removeValue(forKey: "timeZoneID")
        object.removeValue(forKey: "localStartDate")
        var legacy = try JSONDecoder().decode(TripPlan.self, from: JSONSerialization.data(withJSONObject: object))
        try require(legacy.needsTimeZoneReview, "Legacy time zone guessed without review")
        try require(TripSurfacePlan(legacy).days[0].agenda[0].requiresTimeReview == true, "Legacy warning lost")
        let civil = TripLocalDate(year: 2026, month: 10, day: 16)
        try require(legacy.reviewTimeZone("Asia/Tokyo", departure: civil), "Reviewed zone rejected")
        try require(legacy.events[0].departureTime?.minute == 480, "Migration moved the booking’s clock time")
        let restored = try JSONDecoder().decode(TripPlan.self, from: JSONEncoder().encode(legacy))
        try require(restored.localStartDate == civil && !restored.needsTimeZoneReview, "Civil date failed round trip")
        try require(restored.events == legacy.events, "Zoned bookings failed round trip")
    }

    private static func stableDates() throws {
        var trip = TripPlan(title: "DST dates")
        trip.days = (1...3).map { TripDay(number: $0) }
        _ = trip.reviewTimeZone("America/New_York", departure: TripLocalDate(year: 2026, month: 3, day: 7))
        let dates = trip.days.map { trip.date(for: $0) }
        try require(dates[2].timeIntervalSince(dates[1]) == 23 * 3600, "Day arithmetic ignored DST")
        let old = NSTimeZone.default
        defer { NSTimeZone.default = old }
        NSTimeZone.default = TimeZone(identifier: "Pacific/Honolulu")!
        try require(trip.days.map { trip.date(for: $0) } == dates, "Device zone moved trip dates")
        NSTimeZone.default = TimeZone(identifier: "Asia/Tokyo")!
        try require(trip.days.map { trip.date(for: $0) } == dates, "Second device zone moved trip dates")
    }

    private static func projectedClock() throws {
        var trip = TripJourneyFixtures.plan()
        _ = trip.reviewTimeZone("America/New_York", departure: TripLocalDate(year: 2026, month: 11, day: 1))
        trip.events[0].departureTime = TripTimeZoneChecks.clock(2026, 11, 1, 90, "America/New_York")
        trip.days[0].stops[0].timing.arrivalMinute = 90
        let day = TripSurfacePlan(trip).days[0]
        try require(day.agenda[0].startsAt == nil && day.agenda[0].requiresTimeReview == true, "Ambiguous event projected")
        try require(day.agenda[1].startsAt == nil && day.agenda[1].requiresTimeReview == true, "Ambiguous visit projected")
        let now = TripTimeZoneChecks.clock(2026, 11, 1, 180, "America/New_York").instant!
        try require(TripDayBriefing(plan: TripSurfacePlan(trip), date: now).day?.id == day.id, "Briefing used device day")
    }
}
