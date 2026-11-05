#if DEBUG && canImport(trip)
import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite("Trip preparation", .serialized)
struct TripPreparationCoverageTests {
    @Test("Presets preserve completed items and are idempotent", arguments: TripChecklistTemplate.allCases)
    func presets(_ template: TripChecklistTemplate) throws {
        var plan = TripPlan(title: "Packing review")
        var existing = TripChecklistItem(title: try #require(template.items.first))
        existing.isComplete = true
        plan.checklist = [existing]
        #expect(TripChecklistEditing.appendTemplate(template, to: &plan) == template.items.count - 1)
        let identifiers = plan.checklist.map(\.id)
        #expect(TripChecklistEditing.appendTemplate(template, to: &plan) == 0)
        #expect(plan.checklist.map(\.id) == identifiers)
        #expect(plan.checklist.first?.id == existing.id)
        #expect(plan.checklist.first?.isComplete == true)
    }

    @Test("Insufficient capacity never adds a partial preset")
    func fullPreset() {
        var plan = TripPlan(title: "Almost full")
        plan.checklist = (0..<TripLimits.checklistItems - 1).map { TripChecklistItem(title: "Custom \($0)") }
        let identifiers = plan.checklist.map(\.id)
        #expect(TripChecklistEditing.appendTemplate(.essentials, to: &plan) == nil)
        #expect(plan.checklist.map(\.id) == identifiers)
    }

    @Test("Renaming keeps the saved item and completion")
    func rename() {
        var plan = TripPlan(title: "Packing review")
        var item = TripChecklistItem(title: "Umbrella")
        item.isComplete = true
        plan.checklist = [item]
        #expect(TripChecklistEditing.rename(item.id, to: "  Small umbrella  ", in: &plan))
        #expect(plan.checklist[0].id == item.id)
        #expect(plan.checklist[0].title == "Small umbrella")
        #expect(plan.checklist[0].isComplete)
        #expect(!TripChecklistEditing.rename(item.id, to: "Small umbrella", in: &plan))
        #expect(!TripChecklistEditing.rename(UUID(), to: "Another", in: &plan))
    }

    @Test("Invalid checklist titles cannot change saved data", arguments: ["", "Two\nlines", "Tab\titem", String(repeating: "a", count: 81)])
    func invalidTitles(_ title: String) {
        var plan = TripPlan(title: "Packing review")
        let item = TripChecklistItem(title: "Keep this")
        plan.checklist = [item]
        #expect(!TripChecklistEditing.rename(item.id, to: title, in: &plan))
        #expect(plan.checklist[0].title == item.title)
        let draft = TripChecklistDraft(tripID: plan.id, item: item)
        draft.title = title
        #expect(!draft.canSave)
    }

    @Test("Checklist UI and Siri use the same preset policy")
    func samePresetOperation() throws {
        let model = PreviewFixtures.tripPlanner(includeChecklist: false)
        let id = try #require(model.library.trips.first?.id)
        model.addChecklistTemplate(.beach, tripID: id)
        let first = try #require(model.library.trip(id)).checklist.map(\.id)
        model.addChecklistTemplate(.beach, tripID: id)
        #expect(model.library.trip(id)?.checklist.map(\.id) == first)
        #expect(first.count == TripChecklistTemplate.beach.items.count)
    }
}
#endif
