import Foundation
#if !TRIP_STANDALONE
import TripLocalization
#endif

/// Spoken and visual answers are assembled exclusively from saved records.
public nonisolated struct TripDetailAnswer: Sendable {
    public let plan: TripSurfacePlan
    public let query: TripDetailQuery
    public let results: [TripDetailResult]

    public init(plan: TripSurfacePlan, query: TripDetailQuery) {
        self.plan = plan
        self.query = query
        results = query.results(in: plan)
    }

    public var scope: String {
        let day = query.dayNumber.map { TripText.dayTitle($0).text } ?? TripText.wholeTrip.text
        return [query.category.title, day, query.searchText].filter { !$0.isEmpty }.joined(separator: " · ")
    }

    public var summary: String {
        guard query.category != .unsupported else {
            return TripText.askAboutSavedPlacesStaysFlightsReservationsOrTimes.text
        }
        guard !results.isEmpty else { return TripText.noSavedDetailsMatchThisSearchTryTheWhole.text }
        let details = results.prefix(3).map {
            [$0.item.title, $0.item.detail, $0.item.timeText, $0.source].filter { !$0.isEmpty }.joined(separator: ", ")
        }.joined(separator: "; ")
        let remaining = results.count > 3
            ? TripText.plusValueMoreItemsOpenTripForTheFull(TripText.number(results.count - 3)).text : ""
        return [plan.title, scope, details, remaining].filter { !$0.isEmpty }.joined(separator: ". ")
    }
}
