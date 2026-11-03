import Foundation

enum TripJourneyPersistenceChecks {
    static func run() throws {
        try roundTrip()
        try legacyTrip()
        try externalStopOrder()
    }

    private static func roundTrip() throws {
        let trip = TripJourneyFixtures.plan()
        let restored = try JSONDecoder().decode(TripPlan.self, from: JSONEncoder().encode(trip))
        try require(restored.events == trip.events && restored.days == trip.days, "Saved journey details lost")
        try require(restored.journeyItems(on: restored.days[0]).map(\.id) == trip.days[0].itemOrder, "Saved order lost")
        let copy = TripPlan(copying: trip)
        try require(copy.id != trip.id && copy.events == trip.events, "Duplicate trip lost events")
        try require(copy.events.allSatisfy { $0.dayRange(in: copy) != nil }, "Copied event references broken")
    }

    private static func legacyTrip() throws {
        let trip = TripJourneyFixtures.plan()
        let data = try JSONEncoder().encode(trip)
        var object = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        object.removeValue(forKey: "events")
        var days = object["days"] as! [[String: Any]]
        for index in days.indices { days[index].removeValue(forKey: "itemOrder") }
        object["days"] = days
        let restored = try JSONDecoder().decode(TripPlan.self, from: JSONSerialization.data(withJSONObject: object))
        try require(restored.events.isEmpty && restored.days.allSatisfy { $0.itemOrder.isEmpty }, "Legacy defaults missing")
        try require(restored.id == trip.id && restored.days[0].stops == trip.days[0].stops, "Legacy identities changed")
    }

    private static func externalStopOrder() throws {
        var trip = TripJourneyFixtures.plan()
        let additional = TripStop(place: CheckFixtures.place("second-place"))
        trip.days[0].stops.append(additional)
        let items = trip.journeyItems(on: trip.days[0])
        try require(items.last?.id == additional.id, "New place not appended")
        try require(trip.setJourneyOrder(items, dayID: trip.days[0].id), "Could not record order")
        trip.days[0].stops.reverse()
        let reversed = trip.journeyItems(on: trip.days[0])
        try require(reversed.compactMap(\.stop) == trip.days[0].stops, "Suggested place order ignored")
        try require(reversed.count == items.count, "Place reordering dropped an event")
    }
}
