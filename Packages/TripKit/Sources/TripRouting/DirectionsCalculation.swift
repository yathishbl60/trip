import MapKit
import Foundation

@MainActor public struct DirectionsCalculation {
    private let provider: any DirectionsProviding

    public init(provider: any DirectionsProviding) { self.provider = provider }

    public func calculate(_ plan: DirectionsPlan) async throws -> [DirectionsResponse] {
        let backwards = plan.options.timing == .arriveBy
        var date = plan.options.timing == .now ? Date.now : plan.options.date
        var result: [DirectionsResponse] = []
        for request in backwards ? Array(plan.requests.reversed()) : plan.requests {
            try Task.checkCancellation()
            if backwards { request.arrivalDate = date }
            else { request.departureDate = date }
            let response = try await provider.calculate(request, etaOnly: plan.mode == .transit)
            try Task.checkCancellation()
            result.append(response)
            date = try nextDate(date, response: response, backwards: backwards)
        }
        return backwards ? Array(result.reversed()) : result
    }

    private func nextDate(_ date: Date, response: DirectionsResponse, backwards: Bool) throws -> Date {
        switch response {
        case .estimate(let estimate):
            return backwards ? estimate.expectedDepartureDate : estimate.expectedArrivalDate
        case .routes(let routes):
            guard let first = routes.first else { throw DirectionsFailure.unavailable }
            return date.addingTimeInterval(first.expectedTravelTime * (backwards ? -1 : 1))
        }
    }
}
