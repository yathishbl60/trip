#if DEBUG
import Foundation
import TripDomain

enum TripSchedulePreview {
    static func planner(overloaded: Bool = false, overnight: Bool = false) -> TripModel {
        let plan = plan(overloaded: overloaded, overnight: overnight)
        return PreviewTripServices.makeTrips([plan])
    }

    static func plan(overloaded: Bool = false, overnight: Bool = false) -> TripPlan {
        var plan = TripPlan(title: "Bangkok weekend")
        plan.startDate = Calendar.current.date(from: DateComponents(year: 2026, month: 10, day: 11)) ?? .distantPast
        var day = TripDay(number: 1)
        day.schedule = TripDaySchedule(startMinute: overnight ? 1320 : 540,
                                       endMinute: overnight ? 180 : (overloaded ? 660 : 1080))
        day.stops = [PreviewFixtures.hotel, PreviewFixtures.longName, PreviewFixtures.unrated].map { TripStop(place: $0) }
        day.stops[0].timing.visitMinutes = overloaded ? 90 : 60
        day.stops[1].timing.arrivalMinute = overnight ? 1440 : (overloaded ? 600 : 720)
        plan.days = [day]
        return plan
    }
}
#endif
