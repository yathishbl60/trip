import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite(.timeLimit(.minutes(1))) struct TripChecklistSelectionTests {
    @Test func selectingAnotherTripDiscardsNamingWithoutSaving() throws {
        let first = TripPlan(title: "First"), second = TripPlan(title: "Second")
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [first, second])
        model.trips.selectTrip(first.id)
        model.trips.checklist.editChecklistItem(in: first.id)
        let draft = try #require(model.trips.checklist.draft)
        draft.title = "Unsaved item"
        model.trips.selectTrip(second.id)
        #expect(model.trips.selectedTripID == second.id && !model.trips.checklist.hasEditingSession)
        #expect(model.trips.library.trip(first.id)?.checklist.isEmpty == true)
    }

    @Test func selectingAnotherTripCancelsPackingAndRejectsItsLateResult() async throws {
        let first = TripPlan(title: "First"), second = TripPlan(title: "Second")
        let planner = ControlledPackingPlanner()
        let packing = packingModel(planner)
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [first, second], packing: packing)
        model.trips.selectTrip(first.id)
        let request = try generate("old", in: model, tripID: first.id)
        await planner.waitForRequest("old")
        model.trips.selectTrip(second.id)
        await planner.finish("old", titles: ["Late suggestion"])
        await request.value
        #expect(model.trips.selectedTripID == second.id && !model.trips.checklist.hasEditingSession)
        #expect(!packing.isGenerating && packing.suggestions.isEmpty)
        #expect(model.trips.library.trip(first.id)?.checklist.isEmpty == true)
    }

    @Test func aDismissedReviewCannotPublishIntoTheReopenedReview() async throws {
        let plan = TripPlan(title: "Weekend")
        let planner = ControlledPackingPlanner()
        let packing = packingModel(planner)
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [plan], packing: packing)
        let old = try generate("old", in: model, tripID: plan.id)
        await planner.waitForRequest("old")
        model.trips.checklist.dismissPacking()
        let current = try generate("current", in: model, tripID: plan.id)
        let sessionID = model.trips.checklist.packingSession?.id
        await planner.waitForRequest("current")
        await planner.finish("current", titles: ["Current suggestion"])
        await current.value
        await planner.finish("old", titles: ["Old suggestion"])
        await old.value
        #expect(model.trips.checklist.packingSession?.id == sessionID)
        #expect(packing.selectedTitles == ["Current suggestion"])
        #expect(model.trips.library.trip(plan.id)?.checklist.isEmpty == true)
    }

    private func packingModel(_ planner: ControlledPackingPlanner) -> TripPackingModel {
        TripPackingModel(client: TripAIClient(makeService: { _ in planner }, availability: { _ in nil },
                                             failureMessage: { _ in "Failed" }))
    }

    private func generate(_ preferences: String, in model: AppModel, tripID: UUID) throws -> Task<Void, Never> {
        model.trips.checklist.openPacking(tripID)
        model.trips.checklist.setPackingPreferences(preferences)
        model.trips.checklist.generatePacking(tripID)
        return try #require(model.trips.checklist.packing.task)
    }
}
