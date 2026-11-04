import Foundation

enum TripJourneyChecks {
    static func run() throws {
        try coexistence()
        try orderAndRemoval()
        try shortenedStay()
        try spanProtection()
        try validation()
        try TripJourneyPersistenceChecks.run()
        try TripStopTransferChecks.run()
    }

    private static func coexistence() throws {
        let trip = TripJourneyFixtures.plan()
        let items = trip.journeyItems(on: trip.days[0])
        try require(items.map(\.id) == trip.days[0].itemOrder, "Mixed journey order changed")
        try require(items.compactMap(\.stop).count == 1, "Events became fake places")
        try require(trip.events[2].startMinute == nil && trip.days[0].schedule == nil, "Walk forced scheduling")
        for day in trip.days.dropFirst() {
            try require(trip.journeyItems(on: day).map(\.id) == [trip.events[1].id], "Stay identity duplicated or missing")
        }
        try require(trip.events.count == 3, "Spanning event stored more than once")
    }

    private static func orderAndRemoval() throws {
        var trip = TripJourneyFixtures.plan()
        let dayID = trip.days[0].id
        let ordered = Array(trip.journeyItems(on: trip.days[0]).reversed())
        try require(trip.setJourneyOrder(ordered, dayID: dayID), "Mixed reordering rejected")
        try require(trip.journeyItems(on: trip.days[0]) == ordered, "Mixed order did not persist")
        trip.days[0].stops.removeAll()
        let items = trip.journeyItems(on: trip.days[0])
        try require(items.count == 3 && items.compactMap(\.stop).isEmpty, "Deleted place remained in timeline")
        try require(!trip.setJourneyOrder(ordered, dayID: dayID), "Stale order resurrected deleted place")
        trip.events.remove(at: 1)
        try require(trip.days.dropFirst().allSatisfy { trip.journeyItems(on: $0).isEmpty }, "Deleted stay still appears")
    }

    private static func shortenedStay() throws {
        var trip = TripJourneyFixtures.plan()
        let stay = trip.events[1]
        let nextDay = trip.days[1].id
        try require(trip.removeJourneyDay(trip.days[0].id), "Could not delete first day")
        try require(trip.events.count == 1 && trip.events[0].id == stay.id, "Day deletion duplicated or lost stay")
        try require(trip.events[0].startDayID == nextDay && trip.events[0].startMinute == nil, "Invalid check-in retained")
        try require(trip.events[0].endMinute == stay.endMinute, "Surviving check-out time changed")
        try require(trip.days.map(\.number) == [1, 2, 3], "Days not renumbered")
        try require(trip.removeJourneyDay(trip.days[2].id), "Could not delete check-out day")
        try require(trip.events[0].endMinute == nil, "Deleted check-out time retained")
    }

    private static func spanProtection() throws {
        var trip = TripJourneyFixtures.plan()
        let original = trip
        trip.days.swapAt(0, 3)
        try require(!trip.preservesEventSpans(from: original), "Reversed stay allowed")
        trip = original
        let revision = TripItineraryRevision(trip)
        try require(!revision.apply(trip.days, to: &trip), "Assistant replaced journey events")
    }

    private static func validation() throws {
        let trip = TripJourneyFixtures.plan()
        var event = trip.events[0]
        event.endMinute = 400
        try require(event.validationIssue(in: trip) != nil, "Backwards same-day event accepted")
        event.endDayID = trip.days[1].id
        try require(event.validationIssue(in: trip) == nil, "Overnight event rejected")
        event.startMinute = -1
        try require(event.validationIssue(in: trip) != nil, "Invalid clock accepted")
        event.startMinute = nil
        event.title = "  "
        try require(event.validationIssue(in: trip) != nil, "Empty event title accepted")
    }
}
