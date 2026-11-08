import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor struct TripChecklistPackingTests {
    @Test func changedItineraryCannotCommitAnOlderPackingReview() {
        let plan = TripPlan(title: "Weekend")
        let model = TripChecklistTestFixtures.model([plan])
        model.openPacking(plan.id)
        selectSuggestions(in: model)
        model.library.update(plan.id) { $0.days.append(TripDay(number: 2)); return true }
        model.savePacking(plan.id)
        #expect(model.trip(plan.id)?.checklist.isEmpty == true)
        #expect(model.packingSession != nil)
    }

    @Test func anotherWindowsChecklistEditsAreDeduplicatedBeforeCommit() {
        let plan = TripPlan(title: "Weekend")
        let model = TripChecklistTestFixtures.model([plan])
        model.openPacking(plan.id)
        selectSuggestions(in: model)
        model.library.update(plan.id) { TripChecklistEditing.append(["Walking shoes"], to: &$0) > 0 }
        model.savePacking(plan.id)
        #expect(model.trip(plan.id)?.checklist.map(\.title) == ["Walking shoes", "Water bottle"])
        #expect(model.packingSession == nil)
    }

    @Test func capacityChangesKeepTheReviewAndNeverPartiallyAppend() {
        let plan = TripPlan(title: "Weekend")
        let model = TripChecklistTestFixtures.model([plan])
        model.openPacking(plan.id)
        selectSuggestions(in: model)
        model.library.update(plan.id) { current in
            current.checklist = (0..<(TripLimits.checklistItems - 1)).map { TripChecklistItem(title: "Item \($0)") }
            return true
        }
        model.savePacking(plan.id)
        #expect(model.trip(plan.id)?.checklist.count == TripLimits.checklistItems - 1)
        #expect(model.packingSession != nil && model.packing.error != nil)
    }

    private func selectSuggestions(in model: TripChecklistModel) {
        model.packing.suggestions = ["Walking shoes", "Water bottle"].map(TripPackingSuggestion.init)
        model.packing.selected = Set(model.packing.suggestions.map(\.id))
    }
}
