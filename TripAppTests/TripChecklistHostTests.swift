import AppIntents
import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor struct TripChecklistHostTests {
    @Test func checklistDraftBlocksExternalNavigationWithoutLosingInput() throws {
        let first = TripPlan(title: "First"), second = TripPlan(title: "Second")
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [first, second])
        model.request(.savedTrip(first.id))
        model.trips.checklist.editChecklistItem(in: first.id)
        let draft = try #require(model.trips.checklist.draft)
        draft.title = "Keep this item"
        model.request(.savedTrip(second.id))
        #expect(model.trips.selectedTripID == first.id && model.trips.hasEditingSession)
        #expect(model.trips.checklist.draft === draft && draft.title == "Keep this item")
    }

    @Test func suspendingPackingPreservesNavigationProtection() {
        let plan = TripPlan(title: "Weekend")
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [plan])
        model.trips.checklist.openPacking(plan.id)
        model.trips.checklist.packing.isGenerating = true
        model.trips.suspendHostServices()
        #expect(model.trips.hasEditingSession && !model.trips.checklist.packing.isGenerating)
        #expect(model.trips.checklist.packingSession?.tripID == plan.id)
    }

    @Test func changedHostEntityCallbackReachesTheChecklistController() {
        let plan = TripPlan(title: "Weekend")
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [plan])
        let itemID = UUID()
        var requested: [String] = []
        model.trips.environment.checklistEntityIdentifier = { identity in
            requested.append(identity.rawValue)
            return nil
        }
        let controller = TripChecklistController(model: model.trips.checklist)
        _ = controller.checklistEntityIdentifier(itemID, tripID: plan.id)
        #expect(requested == [TripChecklistIdentity(tripID: plan.id, itemID: itemID).rawValue])
    }
}
