import Foundation
import TripDomain
@testable import trip

@MainActor enum TripChecklistTestFixtures {
    static func model(_ plans: [TripPlan]) -> TripChecklistModel {
        let library = TripLibraryModel(store: ChecklistTestStore(plans), loadedTrips: plans)
        let client = TripAIClient<any TripPackingPlanning>(makeService: { _ in ChecklistTestPlanner() },
                                                          availability: { _ in nil }, failureMessage: { _ in "Unavailable" })
        return TripChecklistModel(library: library, packing: TripPackingModel(client: client))
    }
}

private actor ChecklistTestStore: TripStoring {
    var plans: [TripPlan]

    init(_ plans: [TripPlan]) { self.plans = plans }
    func load() async throws -> [TripPlan] { plans }
    func save(_ trips: [TripPlan], revision: Int, changedIDs: Set<UUID>?) async throws { plans = trips }
}

private nonisolated struct ChecklistTestPlanner: TripPackingPlanning {
    func suggestions(for context: TripPackingContext, preferences: String) async throws -> [String] {
        ["Walking shoes", "Water bottle"]
    }
}
