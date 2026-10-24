#if DEBUG
import Foundation
import MapKit
import TripDomain
import TripRouting

@MainActor enum TripPlanningPreview {
    static func fixture(inserting: Bool = false) -> (TripModel, TripPlanningDraft) {
        let plan = plan()
        let model = PreviewTripServices.makeTrips([plan])
        let routes = TripPlanningRoutes(provider: UnavailablePlanningRoutes())
        let draft = TripPlanningDraft(trip: plan, day: plan.days[0],
                                      place: inserting ? PreviewFixtures.unrated : nil, index: 0, routes: routes)
        model.presentation.planning = draft
        return (model, draft)
    }

    static func plan() -> TripPlan {
        var plan = TripSchedulePreview.plan(overloaded: true)
        plan.days[0].stops = [PreviewFixtures.hotel, PreviewFixtures.longName].map(TripStop.init)
        plan.days[0].stops[1].timing.arrivalMinute = 600
        let dayID = plan.days[0].id
        var booking = TripEvent(kind: .reservation, title: "Lunch reservation", dayID: dayID)
        booking.startMinute = 630
        booking.endMinute = 690
        booking.reviewLegacyTimes(in: plan)
        plan.events = [booking]
        return plan
    }
}

@MainActor private final class UnavailablePlanningRoutes: DirectionsProviding {
    func calculate(_ request: MKDirections.Request, etaOnly: Bool) async throws -> DirectionsResponse {
        throw DirectionsFailure.unavailable
    }
    func cancel() {}
}
#endif
