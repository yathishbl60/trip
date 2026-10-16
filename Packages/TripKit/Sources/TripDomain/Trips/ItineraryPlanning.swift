import Foundation

public nonisolated protocol ItineraryPlanning: Sendable {
    func generate(places: [Place], preferences: String, dayCount: Int) async throws -> [TripDay]
}
