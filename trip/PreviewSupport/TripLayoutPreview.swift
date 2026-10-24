#if DEBUG
import Foundation
import TripDomain

@MainActor enum TripLayoutPreview {
    static let now = TripLocalDate(year: 2026, month: 10, day: 18)
        .noon(in: TripLocalDate.calendar(zoneID: "Asia/Bangkok"))!

    static func emptyPlanner() -> TripModel {
        var trip = TripPlan(title: "Test")
        trip.days = (1...3).map { TripDay(number: $0) }
        _ = trip.reviewTimeZone("Asia/Bangkok", departure: TripLocalDate(year: 2026, month: 10, day: 22))
        return PreviewTripServices.makeTrips([trip])
    }
}
#endif
