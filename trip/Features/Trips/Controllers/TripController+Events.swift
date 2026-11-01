import Foundation
import SwiftUI
import TripDomain

extension TripController {
    var eventDraft: Binding<TripEventDraft?> {
        let id = model.presentation.eventDraft?.id
        return Binding(get: { model.presentation.eventDraft }, set: { value in
            guard value == nil, model.presentation.eventDraft?.id == id else { return }
            model.presentation.eventDraft = nil
        })
    }

    func beginEvent(dayID: UUID, tripID: UUID, eventID: UUID? = nil, kind: TripEventKind = .activity) {
        model.beginEvent(dayID: dayID, tripID: tripID, eventID: eventID, kind: kind)
    }

    func saveEvent(_ draft: TripEventDraft) { model.saveEvent(draft) }
    func deleteEvent(_ draft: TripEventDraft) { model.deleteEvent(draft) }

    func cancelEvent(_ draft: TripEventDraft) {
        guard model.presentation.eventDraft?.id == draft.id else { return }
        model.presentation.eventDraft = nil
    }

    func eventDeletion(_ draft: TripEventDraft) -> Binding<Bool> {
        Binding(get: { draft.isDeleting }, set: { draft.isDeleting = $0 })
    }

    func requestEventDelete(_ draft: TripEventDraft) { draft.isDeleting = true }

    func requestEventCancel(_ draft: TripEventDraft) {
        if draft.hasChanges { draft.isDiscarding = true }
        else { cancelEvent(draft) }
    }

    func eventDiscarding(_ draft: TripEventDraft) -> Binding<Bool> {
        Binding(get: { draft.isDiscarding }, set: { draft.isDiscarding = $0 })
    }

    func eventFailure(_ draft: TripEventDraft) -> Binding<Bool> {
        Binding(get: { draft.error != nil }, set: { if !$0 { draft.error = nil } })
    }

    func moveJourneyItems(_ offsets: IndexSet, to destination: Int, day: TripDay, trip: TripPlan) {
        model.moveJourneyItems(offsets, to: destination, day: day, trip: trip)
    }

    func removeJourneyVisits(_ offsets: IndexSet, day: TripDay, trip: TripPlan) {
        model.removeJourneyVisits(offsets, day: day, trip: trip)
    }
}
