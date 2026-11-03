import Foundation

enum TripNextStepChecks {
    static func run() throws {
        try activeProgress()
        try exactDay()
        try priorityAndBoundaries()
        try timeReview()
    }

    private static func activeProgress() throws {
        var trip = TripJourneyFixtures.plan()
        trip.days[0].stops.append(TripStop(place: CheckFixtures.place("second-stop")))
        let plan = TripSurfacePlan(trip)
        let day = plan.days[0]
        var journey = TripJourney(tripID: plan.id, dayID: day.id, now: plan.startDate)
        journey.visited = [day.stops[0].id]
        let next = TripNextStep(plan: plan, journey: journey, at: plan.startDate)
        try require(next.isTracking && next.item?.id == day.stops[1].id, "Tracking ignored actual visit progress")
        try require(next.result?.day.id == day.id && next.coordinate == day.stops[1].coordinate, "Next step lost its exact target")
        journey.visited.append(day.stops[1].id)
        let complete = TripNextStep(plan: plan, journey: journey, at: plan.startDate)
        try require(complete.item == nil, "Completed visits substituted another stop")
        try require(complete.summary.hasPrefix("All places visited"), "Visit completion claimed all events were finished")
    }

    private static func exactDay() throws {
        let plan = TripSurfacePlan(TripJourneyFixtures.plan())
        let before = plan.startDate.addingTimeInterval(-86_400)
        let empty = TripNextStep(plan: plan, journey: nil, at: before)
        try require(empty.day == nil && empty.item == nil, "Next step silently substituted a future day")
        let foreign = TripJourney(tripID: UUID(), dayID: plan.days[0].id, now: before)
        try require(TripNextStep(plan: plan, journey: foreign, at: before).item == nil, "Progress crossed trip boundaries")
        let expired = TripJourney(tripID: plan.id, dayID: plan.days[0].id, now: before)
        let current = TripNextStep(plan: plan, journey: expired, at: plan.days[1].date)
        try require(!current.isTracking && current.day?.id == plan.days[1].id, "Expired activity overrode today's itinerary")
    }

    private static func priorityAndBoundaries() throws {
        let now = Date(timeIntervalSince1970: 1_791_331_200)
        let end = now.addingTimeInterval(7_200)
        let flight = TripSurfaceItem(id: UUID(), title: "Flight", symbol: "airplane", kind: .flight,
                                    startsAt: now.addingTimeInterval(3_600), endsAt: end)
        let stay = TripSurfaceItem(id: UUID(), title: "Hotel", symbol: "bed.double", kind: .stay,
                                  startsAt: now.addingTimeInterval(-86_400), endsAt: now.addingTimeInterval(172_800))
        let one = TripSurfaceItem(id: UUID(), title: "First untimed", symbol: "mappin")
        let two = TripSurfaceItem(id: UUID(), title: "Second untimed", symbol: "mappin")
        let day = TripSurfaceDay(id: UUID(), number: 1, date: now, stops: [], items: [stay, one, two, flight], zoneID: "UTC")
        let ordered = TripSurfaceAgenda.prioritized(in: day, at: now)
        try require(ordered.map(\.id) == [flight.id, one.id, two.id, stay.id], "Upcoming order obscured a commitment or changed ties")
        try require(TripSurfaceAgenda.nextChange(in: day, after: now) == flight.startsAt, "Timeline skipped flight departure")
        try require(TripSurfaceAgenda.nextChange(in: day, after: flight.startsAt!) == end, "Timeline skipped flight arrival")
        try require(!TripSurfaceAgenda.prioritized(in: day, at: now, excluding: [one.id]).contains(one), "Visited item remained next")
    }

    private static func timeReview() throws {
        let now = Date(timeIntervalSince1970: 1_791_331_200)
        var unresolved = TripSurfaceItem(id: UUID(), title: "Review this booking", symbol: "clock",
                                        startsAt: now.addingTimeInterval(-3_600))
        unresolved.requiresTimeReview = true
        let day = TripSurfaceDay(id: UUID(), number: 1, date: now, stops: [], items: [unresolved])
        try require(TripSurfaceAgenda.upcoming(in: day, at: now).first?.id == unresolved.id, "Unresolved time hid a booking")
        try require(TripSurfaceAgenda.nextChange(in: day, after: now.addingTimeInterval(-7_200)) == nil,
                    "An unconfirmed clock scheduled a timeline transition")
    }
}
