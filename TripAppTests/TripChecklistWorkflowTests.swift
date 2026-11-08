import Foundation
import SwiftUI
import Testing
import TripDomain
@testable import trip

@MainActor struct TripChecklistWorkflowTests {
    @Test func staleNamingDismissalPreservesTheReplacementDraft() throws {
        let plan = TripPlan(title: "Weekend")
        let model = TripChecklistTestFixtures.model([plan])
        let controller = TripChecklistController(model: model)
        model.editChecklistItem(in: plan.id)
        let oldPresentation = controller.checklistNaming(in: plan.id)
        model.editChecklistItem(in: plan.id)
        let replacement = try #require(model.draft)
        replacement.title = "Passport"
        oldPresentation.wrappedValue = false
        #expect(model.draft?.id == replacement.id && model.hasEditingSession)
        controller.checklistNaming(in: plan.id).wrappedValue = false
        #expect(!model.hasEditingSession && model.trip(plan.id)?.checklist.isEmpty == true)
    }

    @Test func savingUsesCurrentDataAndKeepsUnrelatedEdits() throws {
        let plan = TripPlan(title: "Weekend")
        let model = TripChecklistTestFixtures.model([plan])
        model.editChecklistItem(in: plan.id)
        let draft = try #require(model.draft)
        draft.title = "Passport"
        model.library.update(plan.id) { current in
            current.notes = "Updated in another window"
            current.checklist.append(TripChecklistItem(title: "Tickets"))
            return true
        }
        model.saveChecklistItem(draft)
        let saved = try #require(model.trip(plan.id))
        #expect(saved.notes == "Updated in another window")
        #expect(saved.checklist.map(\.title) == ["Tickets", "Passport"])
        #expect(model.draft == nil)
    }

    @Test func stalePackingDismissalPreservesTheReopenedReview() throws {
        let plan = TripPlan(title: "Weekend")
        let model = TripChecklistTestFixtures.model([plan])
        let controller = TripChecklistController(model: model)
        model.openPacking(plan.id)
        let oldPresentation = controller.packingPresentation(plan.id)
        model.dismissPacking()
        model.openPacking(plan.id)
        let current = try #require(model.packingSession)
        oldPresentation.wrappedValue = false
        #expect(model.packingSession?.id == current.id && model.hasEditingSession)
        model.resetPresentation()
        #expect(!model.hasEditingSession)
    }

    @Test func backgroundCancellationKeepsTheReviewAndSavedChecklist() {
        var plan = TripPlan(title: "Weekend")
        plan.checklist = [TripChecklistItem(title: "Passport")]
        let model = TripChecklistTestFixtures.model([plan])
        model.openPacking(plan.id)
        model.packing.isGenerating = true
        let session = model.packingSession?.id
        TripChecklistController(model: model).packingSceneChanged(.background)
        #expect(model.packingSession?.id == session && model.hasEditingSession)
        #expect(!model.packing.isGenerating)
        #expect(model.trip(plan.id)?.checklist.map(\.id) == plan.checklist.map(\.id))
        #expect(model.trip(plan.id)?.checklist.first?.title == "Passport")
        #expect(model.trip(plan.id)?.checklist.first?.isComplete == false)
    }
}
