import Foundation

enum TripItineraryRevisionChecks {
    static func run() throws {
        try preservesDetails()
        try rejectsStaleAndScheduled()
        try rejectsMissingAndRepeatedVisits()
    }

    private static func fixture() -> TripPlan {
        var trip = TripPlan(title: "Reviewed plan")
        trip.days[0].stops = (0..<3).map { TripStop(place: CheckFixtures.place("review-\($0)")) }
        trip.days[0].stops[0].notes = "Keep this reservation reference"
        trip.days[0].notes = "Keep the day notes"
        return trip
    }

    private static func draft(_ trip: TripPlan) -> [TripDay] {
        var day = TripDay(number: 1)
        day.stops = trip.days[0].stops.reversed().map { TripStop(place: $0.place) }
        return [day]
    }

    private static func preservesDetails() throws {
        var trip = fixture()
        let original = trip.days[0]
        let revision = TripItineraryRevision(trip)
        let replacement = draft(trip)
        try require(revision.apply(replacement, to: &trip), "Valid reviewed plan was rejected")
        try require(trip.days[0].id == original.id, "Applying a draft replaced the day identity")
        try require(trip.days[0].stops == Array(original.stops.reversed()), "Stop identities or notes were lost")
        try require(trip.days[0].notes == original.notes, "Applying a draft erased day notes")
        try require(!revision.apply(replacement, to: &trip), "The same old draft applied twice")
    }

    private static func rejectsStaleAndScheduled() throws {
        var trip = fixture()
        let revision = TripItineraryRevision(trip)
        let replacement = draft(trip)
        trip.days[0].stops[0].notes = "Changed after generation"
        try require(!revision.apply(replacement, to: &trip), "A stale draft overwrote an edit")
        trip.days[0].schedule = TripDaySchedule()
        let scheduled = TripItineraryRevision(trip)
        try require(!scheduled.apply(replacement, to: &trip), "A scheduled day was replaced")
        trip.days[0].schedule = nil
        trip.days[0].stops[0].timing.arrivalMinute = 600
        let fixed = TripItineraryRevision(trip)
        try require(!fixed.apply(replacement, to: &trip), "A fixed reservation was replaced")
    }

    private static func rejectsMissingAndRepeatedVisits() throws {
        var trip = fixture()
        let revision = TripItineraryRevision(trip)
        var replacement = draft(trip)
        replacement[0].stops.removeLast()
        try require(!revision.apply(replacement, to: &trip), "A draft silently dropped a planned place")
        replacement = draft(trip)
        replacement[0].stops.append(replacement[0].stops[0])
        try require(!revision.apply(replacement, to: &trip), "A duplicate generated visit was accepted")
        var extra = TripDay(number: 2)
        extra.stops = [trip.days[0].stops[0]]
        trip.days.append(extra)
        let repeated = TripItineraryRevision(trip)
        try require(!repeated.apply(draft(trip), to: &trip), "An intentional repeat visit was lost")
    }
}
