import Foundation

enum TripTimeZoneChecks {
    static func run() throws {
        try repeatedClock()
        try missingClock()
        try dateLine()
        try TripTimeZonePersistenceChecks.run()
    }

    static func clock(_ year: Int, _ month: Int, _ day: Int, _ minute: Int, _ zone: String) -> TripZonedDateTime {
        TripZonedDateTime(date: TripLocalDate(year: year, month: month, day: day), minute: minute, zoneID: zone)
    }

    private static func repeatedClock() throws {
        var value = clock(2026, 11, 1, 90, "America/New_York")
        try require(value.candidates.count == 2 && value.instant == nil, "Repeated clock time was silently chosen")
        value.occurrence = .first
        let first = value.instant!
        value.occurrence = .last
        try require(value.instant!.timeIntervalSince(first) == 3600, "DST occurrences did not differ by one hour")
        var halfHour = clock(2026, 4, 5, 105, "Australia/Lord_Howe")
        halfHour.occurrence = .first
        let earlier = halfHour.instant!
        halfHour.occurrence = .last
        try require(halfHour.instant!.timeIntervalSince(earlier) == 1800, "Half-hour DST change was lost")
    }

    private static func missingClock() throws {
        let missing = clock(2026, 3, 8, 150, "America/New_York")
        try require(missing.candidates.isEmpty && missing.issue != nil, "Nonexistent local time was shifted")
        try require(clock(2026, 2, 30, 600, "Etc/UTC").instant == nil, "Invalid civil date normalized silently")
        try require(clock(2011, 12, 30, 600, "Pacific/Apia").instant == nil, "Skipped civil day was accepted")
        try require(clock(2026, 1, 1, 600, "Invalid/Zone").instant == nil, "Unknown time zone accepted")
    }

    private static func dateLine() throws {
        var trip = TripPlan(title: "Date line")
        _ = trip.reviewTimeZone("Pacific/Auckland", departure: TripLocalDate(year: 2026, month: 10, day: 16))
        var flight = TripEvent(kind: .flight, title: "Auckland to Honolulu", dayID: trip.days[0].id)
        flight.departureTime = clock(2026, 10, 16, 600, "Pacific/Auckland")
        flight.arrivalTime = clock(2026, 10, 15, 1260, "Pacific/Honolulu")
        try require(flight.elapsedDuration == 10 * 3600, "Date-line travel used wall-clock subtraction")
        try require(flight.validationIssue(in: trip) == nil, "Earlier arrival civil date rejected")
        swap(&flight.departureTime, &flight.arrivalTime)
        try require(flight.validationIssue(in: trip) != nil, "Arrival before departure instant accepted")
    }
}
