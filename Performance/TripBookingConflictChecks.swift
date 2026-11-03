import Foundation

enum TripBookingConflictChecks {
    static func run() throws {
        try overlaps()
        try boundaries()
        try accommodation()
    }

    private static func plan() -> TripPlan {
        var trip = TripPlan(title: "Booking checks")
        trip.timeZoneID = "GMT"
        trip.startDate = TripScheduleFixtures.date
        trip.days = [TripScheduleFixtures.day()]
        return trip
    }

    private static func event(_ trip: TripPlan, start: Int, end: Int?, kind: TripEventKind = .reservation) -> TripEvent {
        var event = TripEvent(kind: kind, title: "Fixed booking", dayID: trip.days[0].id)
        event.startMinute = start
        event.endMinute = end
        return event
    }

    private static func overlaps() throws {
        var trip = plan()
        trip.events = [event(trip, start: 570, end: 580)]
        let timeline = try TripScheduleFixtures.timeline(trip.days[0])
        let found = TripBookingConflict.find(in: trip, timeline: timeline)
        try require(found.count == 1 && found[0].stopID == trip.days[0].stops[0].id, "Missed a visit-booking overlap")
        trip.events = [event(trip, start: 610, end: 620)]
        let transfer = TripBookingConflict.find(in: trip, timeline: timeline)
        try require(transfer.count == 1 && transfer[0].stopID == trip.days[0].stops[1].id, "Missed a travel-booking overlap")
        try require(TripBookingConflict.find(in: trip, timeline: nil).isEmpty, "Invented times for an unscheduled day")
    }

    private static func boundaries() throws {
        var trip = plan()
        let timeline = try TripScheduleFixtures.timeline(trip.days[0])
        trip.events = [event(trip, start: 530, end: 540)]
        try require(TripBookingConflict.find(in: trip, timeline: timeline).isEmpty, "Touching endpoints overlap")
        trip.events = [event(trip, start: 550, end: nil)]
        try require(TripBookingConflict.find(in: trip, timeline: timeline).count == 1, "Missed a fixed booking instant")
        trip.timeZoneID = nil
        try require(TripBookingConflict.find(in: trip, timeline: timeline).isEmpty, "Interpreted an unreviewed time zone")
    }

    private static func accommodation() throws {
        var trip = plan()
        let timeline = try TripScheduleFixtures.timeline(trip.days[0])
        trip.events = [event(trip, start: 400, end: 900, kind: .stay)]
        try require(TripBookingConflict.find(in: trip, timeline: timeline).isEmpty, "A hotel stay blocked the entire day")
        trip.events = [event(trip, start: 550, end: 900, kind: .stay)]
        try require(TripBookingConflict.find(in: trip, timeline: timeline).count == 1, "Missed check-in during a visit")
        trip.events = [event(trip, start: 540, end: 900, kind: .freeTime)]
        try require(TripBookingConflict.find(in: trip, timeline: timeline).isEmpty, "Flexible time became a fixed booking")
    }
}
