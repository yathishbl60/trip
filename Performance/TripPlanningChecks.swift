import Foundation

enum TripPlanningChecks {
    static func run() throws {
        try fixedStops()
        try eventSlots()
        try admission()
        try TripInsertionChecks.run()
        try TripBookingConflictChecks.run()
    }

    private static func fixedStops() throws {
        var day = TripScheduleFixtures.day()
        day.stops[1].timing.arrivalMinute = 600
        let original = day
        try require(!TripDayReordering.move(IndexSet(integer: 0), to: 3, in: &day), "Moved a visit across a fixed arrival")
        try require(day == original, "Rejected move mutated the day")
        try require(!TripDayReordering.move(IndexSet(integer: 1), to: 3, in: &day), "Moved a fixed arrival")
        try require(!TripDayReordering.move(IndexSet(integer: 9), to: 0, in: &day), "Accepted an invalid drag index")
        day.stops[1].timing.arrivalMinute = nil
        try require(TripDayReordering.move(IndexSet(integer: 0), to: 3, in: &day), "Rejected a flexible reorder")
        try require(day.stops.last?.id == original.stops[0].id, "Drag lost the requested identity")
    }

    private static func eventSlots() throws {
        var day = TripScheduleFixtures.day()
        let booking = UUID()
        let first = day.stops[0].id
        day.itemOrder = [first, booking, day.stops[1].id, day.stops[2].id]
        try require(TripDayReordering.move(IndexSet(integer: 0), to: 3, in: &day), "Could not reorder a mixed itinerary")
        try require(day.itemOrder[1] == booking, "Reorder displaced a booking slot")
        try require(day.itemOrder.last == first, "Mixed order disagrees with visit order")
        try require(Set(day.itemOrder).count == 4, "Reorder duplicated or dropped identities")
    }

    private static func admission() throws {
        var day = TripScheduleFixtures.day()
        let place = day.stops[0].place
        try require(TripPlaceInsertion.best(for: place, in: day) == nil, "Recommended a duplicate visit")
        day.stops = (0..<TripLimits.stops).map { TripStop(place: CheckFixtures.place("full-\($0)")) }
        try require(TripPlaceInsertion.best(for: place, in: day) == nil, "Recommended a full day")
        day.stops = []
        let empty = TripPlaceInsertion.best(for: place, in: day)
        try require(empty?.index == 0 && empty?.nearbyName == nil, "Invented a nearby place for an empty day")
        var trip = TripPlan(title: "Insertion")
        trip.days = [day]
        try require(TripPlaceInsertion.suggestions(for: place, in: trip).first?.dayID == day.id, "Lost the empty-day choice")
    }
}
