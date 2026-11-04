import Foundation

enum TripStopTransferValidationChecks {
    static func run() throws {
        try duplicateAndCapacity()
        try staleAndInvalidTargets()
        try emptyDayAndSameDay()
    }

    private static func duplicateAndCapacity() throws {
        var trip = TripJourneyFixtures.plan()
        let stop = trip.days[0].stops[0]
        trip.days[1].stops = [TripStop(place: stop.place)]
        var transfer = TripStopTransfer(sourceIDs: [stop.id], destinationDayID: trip.days[1].id,
                                        beforeID: nil, snapshot: trip)
        let original = trip.days
        try require(!transfer.apply(to: &trip) && trip.days == original, "Duplicate drag changed a day")
        trip.days[1].stops = (0..<TripLimits.stops).map { TripStop(place: CheckFixtures.place("full-\($0)")) }
        transfer = TripStopTransfer(sourceIDs: [stop.id], destinationDayID: trip.days[1].id,
                                   beforeID: nil, snapshot: trip)
        try require(!transfer.apply(to: &trip), "Drag exceeded day capacity")
        try require(trip.days[0].stops == [stop], "Rejected full-day drag removed its source")
    }

    private static func staleAndInvalidTargets() throws {
        var trip = TripJourneyFixtures.plan()
        let stop = trip.days[0].stops[0]
        let transfer = TripStopTransfer(sourceIDs: [stop.id], destinationDayID: trip.days[1].id,
                                        beforeID: nil, snapshot: trip)
        trip.days[0].stops[0].notes = "A newer edit"
        try require(!transfer.apply(to: &trip), "Drag overwrote a newer stop edit")
        let invalid = TripStopTransfer(sourceIDs: [stop.id], destinationDayID: trip.days[1].id,
                                       beforeID: UUID(), snapshot: trip)
        try require(!invalid.apply(to: &trip), "Missing destination silently became end of day")
        let booking = TripStopTransfer(sourceIDs: [trip.events[0].id], destinationDayID: trip.days[1].id,
                                       beforeID: nil, snapshot: trip)
        try require(!booking.apply(to: &trip), "Place drag moved a booking")
    }

    private static func emptyDayAndSameDay() throws {
        var trip = TripJourneyFixtures.plan()
        trip.events = []
        trip.days[0].itemOrder = []
        let first = trip.days[0].stops[0]
        let second = TripStop(place: CheckFixtures.place("same-day"))
        trip.days[0].stops.append(second)
        let reordered = TripStopTransfer(sourceIDs: [second.id], destinationDayID: trip.days[0].id,
                                         beforeID: first.id, snapshot: trip)
        try require(reordered.apply(to: &trip), "Same-day drag rejected")
        try require(trip.days[0].stops == [second, first], "Wrong same-day order")
        let empty = TripStopTransfer(sourceIDs: [first.id], destinationDayID: trip.days[3].id,
                                     beforeID: nil, snapshot: trip)
        try require(empty.apply(to: &trip) && trip.days[3].stops == [first], "Empty-day drop failed")
    }
}
