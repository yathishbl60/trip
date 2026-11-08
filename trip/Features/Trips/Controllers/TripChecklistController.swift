import SwiftUI
import TripDomain
import AppIntents
import Foundation

@MainActor struct TripChecklistController {
    let model: TripChecklistModel

    func checklistNaming(in tripID: UUID) -> Binding<Bool> {
        let draftID = model.draft?.id
        return Binding(get: { model.draft?.tripID == tripID }, set: { presented in
            if !presented { model.dismissNaming(draftID) }
        })
    }

    func checklistTitle(_ draft: TripChecklistDraft) -> Binding<String> {
        Binding(get: { draft.title }, set: { draft.title = $0 })
    }

    func checklistCompletion(_ itemID: UUID, tripID: UUID) -> Binding<Bool> {
        Binding(get: { model.trip(tripID)?.checklist.first(where: { $0.id == itemID })?.isComplete ?? false },
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

    var supportsSystemExports: Bool { model.environment.supportsReminders() }
    func beginRemindersExport(tripID: UUID) { model.environment.showReminders(tripID) }

    func checklistEntityIdentifier(_ itemID: UUID, tripID: UUID) -> EntityIdentifier? {
        model.environment.entityIdentifier(TripChecklistIdentity(tripID: tripID, itemID: itemID))
    }
}
