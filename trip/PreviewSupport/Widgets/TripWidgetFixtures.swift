#if DEBUG && TRIP_WIDGET_EXTENSION
import TripDomain
import Foundation

/// Local sample data, used only for previews and redacted WidgetKit placeholders.
nonisolated enum TripWidgetFixtures {
    static let tripID = UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!
    static let dayID = UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!
    static let stopID = UUID(uuidString: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE")!
    static let date = Date(timeIntervalSince1970: 1_791_331_200)
    static var plan: TripSurfacePlan {
        let park = TripSurfaceStop(id: Self.stopID, name: "Lumphini Park", category: .park,
                                   coordinate: Coordinate(latitude: 13.7308, longitude: 100.5418))
        let day = TripSurfaceDay(id: Self.dayID, number: 1, date: date, stops: [park])
        return TripSurfacePlan(id: Self.tripID, title: "Weekend in Bangkok", startDate: date, days: [day])
    }
    static var planned: TripWidgetEntry {
        let plan = plan
        return TripWidgetEntry(date: date, plan: plan, day: plan.days.first)
    }
    static var active: TripWidgetEntry {
        let plan = plan
        guard let day = plan.days.first else { return planned }
        let journey = TripJourney(tripID: plan.id, dayID: day.id, now: date)
        return TripWidgetEntry(date: date, plan: plan, day: day, journey: journey)
    }
    static var flight: TripWidgetEntry {
        let flight = TripSurfaceItem(id: stopID, title: "Flight to Bangkok", symbol: "airplane", kind: .flight,
                                     startsAt: date.addingTimeInterval(3600), endsAt: date.addingTimeInterval(7200))
        let day = TripSurfaceDay(id: dayID, number: 1, date: date, stops: [], items: [flight])
        let plan = TripSurfacePlan(id: tripID, title: "Long weekend · sample", startDate: date, days: [day])
        return TripWidgetEntry(date: date, plan: plan, day: day)
    }
    static var packing: TripWidgetEntry {
        var plan = plan
        plan.checklistProgress = TripChecklistProgress(total: 12, completed: 8)
        return TripWidgetEntry(date: date.addingTimeInterval(-3 * 86_400), plan: plan, day: plan.days.first)
    }
    static var packed: TripWidgetEntry {
        var entry = packing
        entry.plan?.checklistProgress = TripChecklistProgress(total: 12, completed: 12)
        return entry
    }

    static var flightAfterVisits: TripWidgetEntry {
        let stop = Self.plan.days[0].stops[0]
        let flight = TripSurfaceItem(id: UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!,
            title: "Evening flight to Chiang Mai", symbol: "airplane", kind: .flight,
            startsAt: date.addingTimeInterval(9 * 3600))
        let day = TripSurfaceDay(id: dayID, number: 1, date: date, stops: [stop],
                                 items: [TripSurfaceItem(stop), flight], zoneID: "Asia/Bangkok")
        let plan = TripSurfacePlan(id: tripID, title: "Weekend in Bangkok", startDate: date, days: [day])
        var journey = TripJourney(tripID: tripID, dayID: dayID, now: date)
        journey.visited = [stop.id]
        journey.reconcile(with: day, now: date)
        return TripWidgetEntry(date: date, plan: plan, day: day, journey: journey)
    }
}
#endif
