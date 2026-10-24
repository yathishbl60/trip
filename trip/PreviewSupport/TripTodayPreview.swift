#if DEBUG
import Foundation
import TripDomain

enum TripTodayPreview {
    static let now = Date(timeIntervalSince1970: 1_792_109_400)

    static func planner(review: Bool = false) -> TripModel {
        var trip = TripJourneyPreview.plan()
        _ = trip.reviewTimeZone("Asia/Bangkok", departure: TripLocalDate(year: 2026, month: 10, day: 16))
        trip.events[0].travelAllowanceMinutes = 90
        trip.events[0].notes = "Saved booking details remain available without a connection."
        if review { trip.timeZoneID = nil; trip.localStartDate = nil }
        return PreviewTripServices.makeTrips([trip])
    }
}
#endif
