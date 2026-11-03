import Foundation

enum TripSystemProjectionChecks {
    static func run() throws {
        try projection()
        try legacy()
        try lookup()
        try briefing()
        try PlaceSearchChecks.run()
        try TripSystemActionChecks.run()
        try TripNextStepChecks.run()
        try TripSurfaceSelectionChecks.run()
        try TripPackingChecks.run()
        try TripTimeZoneChecks.run()
        try TripTodayChecks.run()
        try TripZonedScheduleChecks.run()
        try TripScheduleChecks.run()
        try TripJourneyChecks.run()
        try TripBookingImportChecks.run()
    }

    private static func projection() throws {
        var trip = TripJourneyFixtures.plan()
        trip.notes = "PRIVATE_TRIP_NOTE"
        trip.events[0].notes = "PRIVATE_BOOKING_NOTE"
        trip.days[0].stops[0].notes = "PRIVATE_PLACE_NOTE"
        let plan = TripSurfacePlan(trip)
        let day = plan.days[0]
        try require(day.agenda.map(\.id) == trip.days[0].itemOrder, "Projection lost mixed order")
        try require(day.stops.count == 1, "Events became trackable places")
        let text = String(decoding: try JSONEncoder().encode(plan), as: UTF8.self)
        try require(!text.contains("PRIVATE_"), "Private notes leaked to system surfaces")
        let flight = day.agenda[0]
        try require(flight.startsAt != nil && flight.endsAt != nil, "Flight times lost")
        let later = TripSurfaceAgenda.upcoming(in: day, at: flight.endsAt!.addingTimeInterval(1))
        try require(!later.contains { $0.id == flight.id }, "Finished event remained upcoming")
    }

    private static func legacy() throws {
        let day = TripSurfacePlan(TripJourneyFixtures.plan()).days[0]
        let data = try JSONEncoder().encode(day)
        var object = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        object.removeValue(forKey: "items")
        let restored = try JSONDecoder().decode(TripSurfaceDay.self,
            from: JSONSerialization.data(withJSONObject: object))
        try require(restored.items == nil && restored.agenda.count == day.stops.count, "Legacy projection failed")
        try require(restored.agenda.first?.id == day.stops.first?.id, "Legacy identities changed")
    }

    private static func lookup() throws {
        let plan = TripSurfacePlan(TripJourneyFixtures.plan())
        let stays = TripDetailQuery(category: .stays).results(in: plan)
        try require(stays.count == 1, "Multi-day stay duplicated in whole-trip results")
        let middle = TripDetailQuery(category: .stays, dayNumber: 2).results(in: plan)
        try require(middle.first?.id == stays.first?.id, "Middle day lost spanning stay")
        try require(TripDetailQuery(category: .travel).results(in: plan).count == 1, "Travel filter failed")
        try require(TripDetailQuery(category: .unsupported).results(in: plan).isEmpty, "Unsupported question matched")
        try require(TripDetailQuery(dayNumber: 29).results(in: plan).isEmpty, "Unknown day substituted")
    }

    private static func briefing() throws {
        let plan = TripSurfacePlan(TripJourneyFixtures.plan())
        let briefing = TripDayBriefing(plan: plan, date: plan.startDate)
        try require(briefing.items.count == 4, "Briefing omitted journey events")
        try require(briefing.text.contains("Flight"), "Siri omitted travel")
        let outside = TripDayBriefing(plan: plan, date: plan.startDate.addingTimeInterval(-86_400))
        try require(outside.day == nil && outside.items.isEmpty, "Briefing substituted a different date")
    }
}
