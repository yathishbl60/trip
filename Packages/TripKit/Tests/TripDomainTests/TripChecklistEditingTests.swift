import Foundation
import Testing
import TripDomain

struct TripChecklistEditingTests {
    @Test func completionIsIdempotentAndPreservesIdentityAndOtherFields() {
        var plan = TripPlan(title: "Weekend")
        let item = TripChecklistItem(title: "Passport")
        plan.checklist = [item, TripChecklistItem(title: "Tickets")]
        plan.notes = "Keep these notes"
        #expect(TripChecklistEditing.setComplete(item.id, complete: true, in: &plan))
        #expect(!TripChecklistEditing.setComplete(item.id, complete: true, in: &plan))
        #expect(plan.checklist[0].id == item.id && plan.checklist[0].title == item.title)
        #expect(plan.checklist[0].isComplete && !plan.checklist[1].isComplete)
        #expect(plan.notes == "Keep these notes")
        #expect(TripChecklistEditing.setComplete(item.id, complete: false, in: &plan))
        #expect(!plan.checklist[0].isComplete)
    }

    @Test func missingIdentityDoesNotChangeAnotherItem() {
        var plan = TripPlan(title: "Weekend")
        let item = TripChecklistItem(title: "Passport")
        plan.checklist = [item]
        #expect(!TripChecklistEditing.setComplete(UUID(), complete: true, in: &plan))
        #expect(plan.checklist.map(\.id) == [item.id])
        #expect(plan.checklist.first?.title == item.title && plan.checklist.first?.isComplete == false)
    }
}
