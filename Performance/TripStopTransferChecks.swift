import Foundation

enum TripStopTransferChecks {
    static func run() throws {
        try crossDayRetention()
        try multipleStops()
        try fixedArrivalProtection()
        try TripStopTransferValidationChecks.run()
    }

    private static func crossDayRetention() throws {
        var trip = TripJourneyFixtures.plan()
        trip.days[0].stops[0].notes = "Keep my notes"
        trip.days[0].stops[0].timing = TripStopTiming(visitMinutes: 95, travelMinutes: 20, bufferMinutes: 15)
        let stop = trip.days[0].stops[0]
        let events = trip.events
        let destination = trip.days[1].id
        let transfer = TripStopTransfer(sourceIDs: [stop.id], destinationDayID: destination,
                                        beforeID: events[1].id, snapshot: trip)
        try require(transfer.apply(to: &trip), "Valid cross-day drag rejected")
        try require(trip.days[0].stops.isEmpty, "Dragged stop remained in source day")
        try require(trip.days[1].stops == [stop], "Drag changed identity, notes or allowances")
        try require(trip.events == events, "Drag changed journey bookings")
        try require(trip.journeyItems(on: trip.days[1]).map(\.id) == [stop.id, events[1].id], "Wrong mixed drop slot")
        try require(!transfer.apply(to: &trip), "Repeated stale drop duplicated a stop")
    }

    private static func multipleStops() throws {
        var trip = TripJourneyFixtures.plan()
        let second = TripStop(place: CheckFixtures.place("transfer-second"))
        trip.days[1].stops.append(second)
        let ids = [second.id, trip.days[0].stops[0].id]
        let transfer = TripStopTransfer(sourceIDs: ids, destinationDayID: trip.days[2].id,
                                        beforeID: nil, snapshot: trip)
        try require(transfer.apply(to: &trip), "Multiple-source drag rejected")
        try require(trip.days[0].stops.isEmpty && trip.days[1].stops.isEmpty, "Multi-drag copied its sources")
        try require(trip.days[2].stops.map(\.id) == ids, "Multi-drag changed source order")
        try require(trip.days[2].itemOrder.suffix(2) == ids[...], "End-of-day placement lost")
    }

    private static func fixedArrivalProtection() throws {
        var trip = TripJourneyFixtures.plan()
        var fixed = TripStop(place: CheckFixtures.place("transfer-fixed"))
        fixed.timing.arrivalMinute = 600
        trip.days[0].stops.append(fixed)
        let original = trip.days
        let pinned = TripStopTransfer(sourceIDs: [fixed.id], destinationDayID: trip.days[1].id,
                                      beforeID: nil, snapshot: trip)
        try require(!pinned.apply(to: &trip), "Pinned stop moved to another day")
        let crossing = TripStopTransfer(sourceIDs: [trip.days[0].stops[0].id], destinationDayID: trip.days[0].id,
                                        beforeID: nil, snapshot: trip)
        try require(!crossing.apply(to: &trip), "Drag crossed a fixed arrival")
        try require(trip.days == original, "Rejected move was not atomic")
    }
}
