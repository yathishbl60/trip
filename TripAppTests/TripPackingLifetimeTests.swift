import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite(.timeLimit(.minutes(1))) struct TripPackingLifetimeTests {
    @Test func lateEarlierSuggestionsCannotReplaceTheNewerReview() async throws {
        let plan = TripPlan(title: "Weekend"), planner = ControlledPackingPlanner()
        let model = packingModel(planner)
        let old = try generate("old", in: model, plan: plan)
        await planner.waitForRequest("old")
        let current = try generate("current", in: model, plan: plan)
        await planner.waitForRequest("current")
        await planner.finish("current", titles: ["New suggestion"])
        await current.value
        await planner.finish("old", titles: ["Old suggestion"])
        await old.value
        #expect(model.suggestions.map(\.title) == ["New suggestion"])
        #expect(model.selectedTitles == ["New suggestion"] && !model.isGenerating)
    }

    @Test func canceledGenerationCannotPublishAfterTheProviderReturns() async throws {
        let plan = TripPlan(title: "Weekend"), planner = ControlledPackingPlanner()
        let model = packingModel(planner)
        let request = try generate("canceled", in: model, plan: plan)
        await planner.waitForRequest("canceled")
        model.cancel()
        await planner.finish("canceled", titles: ["Late suggestion"])
        await request.value
        #expect(model.suggestions.isEmpty && model.selected.isEmpty)
        #expect(!model.isGenerating && model.error == nil)
    }

    private func packingModel(_ planner: ControlledPackingPlanner) -> TripPackingModel {
        TripPackingModel(client: TripAIClient(makeService: { _ in planner }, availability: { _ in nil },
                                             failureMessage: { _ in "Failed" }))
    }

    private func generate(_ preferences: String, in model: TripPackingModel, plan: TripPlan) throws -> Task<Void, Never> {
        model.setPreferences(preferences)
        model.generate(plan)
        return try #require(model.task)
    }
}
