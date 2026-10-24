#if DEBUG
import Foundation
import TripDomain

nonisolated struct PreviewItineraryPlanner: ItineraryPlanning {
    func generate(places: [Place], preferences: String, dayCount: Int) async throws -> [TripDay] {
        try Task.checkCancellation()
        var days = (1...max(1, min(dayCount, 5))).map { TripDay(number: $0) }
        for (index, place) in places.enumerated() {
            days[index % days.count].stops.append(TripStop(place: place))
        }
        return days
    }
}

nonisolated struct PreviewPackingPlanner: TripPackingPlanning {
    func suggestions(for context: TripPackingContext, preferences: String) async throws -> [String] {
        try Task.checkCancellation()
        return ["Sample walking shoes", "Sample rain jacket"]
    }
}

nonisolated struct PreviewDetailSearch: TripDetailSearching {
    func interpret(_ question: String, days: [TripSurfaceDay], now: Date) async throws -> TripDetailQuery {
        try Task.checkCancellation()
        return TripDetailQuery(category: .stays)
    }
}

nonisolated struct PreviewStopOrderService: TripStopOrderSuggesting {
    func suggestion(for day: TripDay) async throws -> TripStopOrderProposal {
        try Task.checkCancellation()
        return TripStopOrderProposal(day: day, suggestedIDs: day.stops.map(\.id),
                                     originalDistance: 0, suggestedDistance: 0)
    }
}
#endif
