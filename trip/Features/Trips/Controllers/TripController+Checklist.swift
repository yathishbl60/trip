import SwiftUI
import TripDomain

extension TripController {
    func checklistNaming(in tripID: UUID) -> Binding<Bool> {
        let draftID = model.presentation.checklistDraft?.id
        return Binding(get: { model.presentation.checklistDraft?.tripID == tripID }, set: { presented in
            guard !presented, model.presentation.checklistDraft?.id == draftID else { return }
            model.presentation.checklistDraft = nil
        })
    }

    func checklistTitle(_ draft: TripChecklistDraft) -> Binding<String> {
        Binding(get: { draft.title }, set: { draft.title = $0 })
    }

    func checklistCompletion(_ itemID: UUID, tripID: UUID) -> Binding<Bool> {
        Binding(get: { model.library.trip(tripID)?.checklist.first(where: { $0.id == itemID })?.isComplete ?? false },
                set: { model.setChecklistItem(itemID, complete: $0, tripID: tripID) })
    }

    func editChecklistItem(in tripID: UUID, item: TripChecklistItem? = nil) {
        model.editChecklistItem(in: tripID, item: item)
    }

    func saveChecklistItem(_ draft: TripChecklistDraft) { model.saveChecklistItem(draft) }
    func addChecklistTemplate(_ template: TripChecklistTemplate, tripID: UUID) {
        model.addChecklistTemplate(template, tripID: tripID)
    }
    func removeChecklistItems(_ offsets: IndexSet, snapshot: [TripChecklistItem], tripID: UUID) {
        model.removeChecklistItems(offsets, snapshot: snapshot, tripID: tripID)
    }
    func resetChecklist(in tripID: UUID) { model.resetChecklist(in: tripID) }
    func toggleChecklistItem(_ itemID: UUID, tripID: UUID) {
        let completion = checklistCompletion(itemID, tripID: tripID)
        completion.wrappedValue.toggle()
    }
}
