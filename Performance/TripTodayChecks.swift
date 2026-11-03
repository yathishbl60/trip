import Foundation

enum TripTodayChecks {
    static func run() throws {
        try nextCommitment()
        try progressAndAllowance()
        try reviewAndOutside()
    }

    private static func plan() -> TripPlan {
        var trip = TripJourneyFixtures.plan()
        _ = trip.reviewTimeZone("Asia/Bangkok", departure: TripLocalDate(year: 2026, month: 10, day: 16))
        trip.events[0].travelAllowanceMinutes = 90
        return trip
    }

    private static func nextCommitment() throws {
        let trip = plan()
        let now = TripTimeZoneChecks.clock(2026, 10, 16, 420, "Asia/Bangkok").instant!
        let today = TripTodaySnapshot(trip: trip, at: now)
        try require(today.next?.id == trip.events[0].id, "Untimed visit hid upcoming flight")
        try require(today.next?.leaveBy == now.addingTimeInterval(-1800), "Manual leave-by calculation wrong")
        let later = TripTimeZoneChecks.clock(2026, 10, 16, 1020, "Asia/Bangkok").instant!
        let snapshot = TripTodaySnapshot(trip: trip, at: later)
        try require(snapshot.next?.id == trip.days[0].stops[0].id, "Ongoing hotel hid next unvisited place")
        try require(snapshot.items.count == 4, "Today lost saved details")
    }

    private static func progressAndAllowance() throws {
        var trip = plan()
        trip.days[0].stops[0].timing.arrivalMinute = 720
        let now = TripTimeZoneChecks.clock(2026, 10, 16, 660, "Asia/Bangkok").instant!
        var journey = TripJourney(tripID: trip.id, dayID: trip.days[0].id, now: now)
        journey.visited = [trip.days[0].stops[0].id]
        let next = TripTodaySnapshot(trip: trip, at: now).next!
        try require(next.id == trip.days[0].stops[0].id && next.leaveBy == now.addingTimeInterval(35 * 60), "First-place allowance lost")
        try require(TripTodaySnapshot(trip: trip, at: now, journey: journey).next?.id != next.id, "Visited place remained next")
        let other = TripJourney(tripID: UUID(), dayID: trip.days[0].id, now: now)
        try require(TripTodaySnapshot(trip: trip, at: now, journey: other).next?.id == next.id, "Other trip progress leaked")
    }

    private static func reviewAndOutside() throws {
        var trip = plan()
        let now = TripTimeZoneChecks.clock(2026, 10, 16, 420, "Asia/Bangkok").instant!
        trip.timeZoneID = nil
        trip.localStartDate = nil
        let review = TripTodaySnapshot(trip: trip, at: now)
        try require(review.needsTimeZoneReview && review.items.allSatisfy { $0.leaveBy == nil }, "Unreviewed zone produced leave-by")
        let valid = plan()
        let outside = TripTodaySnapshot(trip: valid, at: now.addingTimeInterval(-86400))
        try require(outside.day == nil && outside.next == nil, "Today substituted a future day")
        var empty = valid
        empty.events = []
        empty.days[0].stops = []
        try require(TripTodaySnapshot(trip: empty, at: now).next == nil, "Empty day invented a commitment")
    }
}
