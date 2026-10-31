import TripLocalization
import Foundation
import TripDomain

extension TripModel {
    func editChecklistItem(in tripID: UUID, item: TripChecklistItem? = nil) {
        guard let trip = library.trip(tripID), item != nil || trip.checklist.count < TripLimits.checklistItems else { return }
        presentation.checklistDraft = TripChecklistDraft(tripID: tripID, item: item)
    }

    func saveChecklistItem(_ draft: TripChecklistDraft) {
        guard presentation.checklistDraft?.id == draft.id, draft.canSave else { return }
        let saved = library.update(draft.tripID) { trip in
            if let id = draft.itemID {
                guard let index = trip.checklist.firstIndex(where: { $0.id == id }) else { return false }
                trip.checklist[index].title = draft.normalizedTitle
            } else {
                guard trip.checklist.count < TripLimits.checklistItems else { return false }
                trip.checklist.append(TripChecklistItem(title: draft.normalizedTitle))
            }
            return true
        }
        if saved { presentation.checklistDraft = nil }
    }

    func setChecklistItem(_ itemID: UUID, complete: Bool, tripID: UUID) {
        library.update(tripID) { trip in
            guard let index = trip.checklist.firstIndex(where: { $0.id == itemID }),
                  trip.checklist[index].isComplete != complete else { return false }
            trip.checklist[index].isComplete = complete
            return true
        }
    }

    func removeChecklistItems(_ offsets: IndexSet, snapshot: [TripChecklistItem], tripID: UUID) {
        guard let edit = IdentifiedListEdit.removing(offsets, from: snapshot.map(\.id)) else { return }
        library.update(tripID) { edit.apply(to: &$0.checklist) }
    }

    func addChecklistTemplate(_ template: TripChecklistTemplate, tripID: UUID) {
        let added = library.update(tripID) { trip in
            let titles = Set(trip.checklist.map { $0.title.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) })
            let missing = template.items.filter { !titles.contains($0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)) }
            let space = max(0, TripLimits.checklistItems - trip.checklist.count)
            guard !missing.isEmpty, space > 0 else { return false }
            trip.checklist += missing.prefix(space).map { TripChecklistItem(title: $0) }
            return true
        }
        feedback.show(added ? TripText.addedToYourChecklist.text : TripText.theseItemsAreAlreadyAddedOrYourChecklistIs.text)
    }

    func resetChecklist(in tripID: UUID) {
        library.update(tripID) { trip in
            guard trip.checklist.contains(where: \.isComplete) else { return false }
            for index in trip.checklist.indices { trip.checklist[index].isComplete = false }
            return true
        }
    }
}
