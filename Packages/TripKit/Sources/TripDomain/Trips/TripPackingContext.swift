import Foundation

/// Only this small, non-identifying snapshot is supplied to the packing model.
public nonisolated struct TripPackingContext: Equatable, Sendable {
    public let days: Int
    public let activities: [String]
    public let journeys: [String]

    public init(_ plan: TripPlan) {
        days = min(TripLimits.days, max(1, plan.days.count))
        activities = Set(plan.savedPlaces.map { $0.category.rawValue }).sorted()
        journeys = Set(plan.events.map { $0.kind.rawValue }).sorted()
    }
}

public nonisolated protocol TripPackingPlanning: Sendable {
    func suggestions(for context: TripPackingContext, preferences: String) async throws -> [String]
}
