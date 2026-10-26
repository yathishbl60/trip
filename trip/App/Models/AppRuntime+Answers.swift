import Foundation
import TripDomain
import TripLocalization

extension AppRuntime {
    static func answerQuestion(_ question: String, tripID: UUID) async throws -> TripDetailAnswer {
        let source = TripSurfacePlan(try await trip(tripID))
        let lookup = AppTripServices.makeLookup()
        let query = try await lookup.interpret(question, plan: source)
        try Task.checkCancellation()
        let current = TripSurfacePlan(try await trip(tripID))
        guard source.days == current.days else {
            throw TripIntelligenceError.unavailable(TripText.yourItineraryChangedSearchAgainForTheLatestDetails.text)
        }
        return TripDetailAnswer(plan: current, query: query)
    }
}
