import SwiftUI

extension TripController {
    func editDraft(savingPlace: Bool) -> Binding<TripEditDraft?> {
        let draftID = model.presentation.editDraft?.id
        return Binding(get: {
            guard let draft = model.presentation.editDraft,
                  (draft.placeToSave != nil) == savingPlace else { return nil }
            return draft
        }, set: { value in
            guard value == nil, let draftID,
                  let draft = model.presentation.editDraft,
                  draft.id == draftID else { return }
            model.cancelEdit(draft)
        })
    }

    func draftTitle(_ draft: TripEditDraft) -> Binding<String> {
        Binding(get: { draft.title }, set: { draft.title = $0 })
    }

    func draftDate(_ draft: TripEditDraft) -> Binding<Date> {
        Binding(get: { draft.startDate }, set: { draft.startDate = $0 })
    }

    func draftNotes(_ draft: TripEditDraft) -> Binding<String> {
        Binding(get: { draft.notes }, set: { draft.notes = $0 })
    }

    func draftTimeZone(_ draft: TripEditDraft) -> Binding<String> {
        Binding(get: { draft.timeZoneID }, set: draft.reviewTimeZone)
    }

    func confirmTimeZone(_ draft: TripEditDraft) { draft.reviewTimeZone(draft.timeZoneID) }

    func saveEdit(_ draft: TripEditDraft) { model.saveEdit(draft) }
    func cancelEdit(_ draft: TripEditDraft) { model.cancelEdit(draft) }
}
