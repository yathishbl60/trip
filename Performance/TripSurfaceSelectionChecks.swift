import Foundation

enum TripSurfaceSelectionChecks {
    static func run() throws {
        try overnightTracking()
        try finishedVisits()
        try expiredTracking()
        try removedTargets()
    }

    private static var plan: TripSurfacePlan {
        let start = Date(timeIntervalSince1970: 0)
        let stop = TripSurfaceStop(id: UUID(), name: "Park", category: .park,
                                  coordinate: Coordinate(latitude: 13, longitude: 100))
        let flight = TripSurfaceItem(id: UUID(), title: "Evening flight", symbol: "airplane", kind: .flight,
                                    startsAt: start.addingTimeInterval(72_000))
        let first = TripSurfaceDay(id: UUID(), number: 1, date: start, stops: [stop],
                                   items: [TripSurfaceItem(stop), flight], zoneID: "UTC")
        let second = TripSurfaceDay(id: UUID(), number: 2, date: start.addingTimeInterval(86_400), stops: [], zoneID: "UTC")
        return TripSurfacePlan(id: UUID(), title: "Selection check", startDate: start, days: [first, second])
    }

    private static func overnightTracking() throws {
        let plan = plan
        let now = plan.days[1].date.addingTimeInterval(600)
        var journey = TripJourney(tripID: plan.id, dayID: plan.days[0].id, now: now.addingTimeInterval(-1_200))
        let active = TripSurfaceSelection(plan: plan, journey: journey, at: now)
        try require(active.day?.id == plan.days[0].id, "Active overnight tracking lost its day")
        journey.isActive = false
        let ended = TripSurfaceSelection(plan: plan, journey: journey, at: now)
        try require(ended.day?.id == plan.days[1].id && ended.journey == nil, "Ended tracking hid today's itinerary")
    }

    private static func finishedVisits() throws {
        let plan = plan
        let day = plan.days[0]
        var journey = TripJourney(tripID: plan.id, dayID: day.id, now: plan.startDate)
        journey.visited = day.stops.map(\.id)
        let selection = TripSurfaceSelection(plan: plan, journey: journey, at: plan.startDate)
        try require(selection.journey?.isActive == false, "Completed visits still exposed tracking actions")
        try require(selection.journey?.visited == journey.visited, "Completed visits were discarded")
        let upcoming = TripSurfaceAgenda.prioritized(in: selection.day!, at: plan.startDate,
                                                     excluding: Set(selection.journey?.visited ?? []))
        try require(upcoming.map(\.kind) == [.flight], "Visit completion hid a flight or repeated a visited place")
    }

    private static func expiredTracking() throws {
        let plan = plan
        let journey = TripJourney(tripID: plan.id, dayID: plan.days[0].id, now: plan.startDate)
        let expired = TripSurfaceSelection(plan: plan, journey: journey, at: journey.expiresAt)
        try require(expired.day?.id == plan.days[0].id, "Expiry lost the current itinerary")
        try require(expired.journey?.isActive == false, "Expired tracking remained actionable")
        let tomorrow = TripSurfaceSelection(plan: plan, journey: journey, at: plan.days[1].date)
        try require(tomorrow.day?.id == plan.days[1].id && tomorrow.journey == nil, "Expired tracking pinned yesterday")
    }

    private static func removedTargets() throws {
        let plan = plan
        let foreign = TripJourney(tripID: UUID(), dayID: plan.days[0].id, now: plan.startDate)
        let deleted = TripJourney(tripID: plan.id, dayID: UUID(), now: plan.startDate)
        for journey in [foreign, deleted] {
            let selection = TripSurfaceSelection(plan: plan, journey: journey, at: plan.startDate)
            try require(selection.journey == nil && selection.day?.id == plan.days[0].id, "Stale target changed the itinerary")
        }
    }
}
