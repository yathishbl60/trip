import TripLocalization
import TripDomain
import Foundation

extension TripModel {
    func beginCreate(saving place: Place? = nil) {
        guard library.isReady, library.canCreate else { return }
        guard presentation.editDraft == nil, place != nil || !hasEditingSession else { return }
        presentation.editDraft = TripEditDraft(placeToSave: place)
    }

    func beginEdit(_ id: UUID) {
        guard !hasEditingSession else { return }
        guard let trip = library.trip(id) else { return }
        presentation.editDraft = TripEditDraft(trip: trip)
    }

    func cancelEdit(_ draft: TripEditDraft) {
        guard presentation.editDraft?.id == draft.id else { return }
        presentation.editDraft = nil
    }

    func saveEdit(_ draft: TripEditDraft) {
        guard presentation.editDraft?.id == draft.id, draft.canSave else { return }
        if let id = draft.tripID {
            guard library.update(id, edit: { trip in
                draft.apply(to: &trip)
            }) else {
                if draft.error == nil { draft.error = TripText.thisTripIsNoLongerAvailableCloseToReturn.text }
                return
            }
            cancelEdit(draft)
        } else {
            createTrip(from: draft)
        }
    }

    private func createTrip(from draft: TripEditDraft) {
        var trip = TripPlan(title: draft.normalizedTitle)
        draft.apply(to: &trip)
        if let place = draft.placeToSave { trip.days[0].stops.append(TripStop(place: place)) }
        guard library.insert(trip) else {
            draft.error = TripText.couldnTCreateThisTripTryAgainOrDelete.text
            return
        }
        cancelEdit(draft)
        if draft.placeToSave == nil { selectTrip(trip.id) }
        else {
            feedback.show(TripText.addedToValue(trip.title).text)
            dismissDestination()
        }
    }

    func deleteTrip() {
        guard let id = presentation.tripToDelete else { return }
        presentation.tripToDelete = nil
        library.remove(id)
        if selectedTripID == id { selectTrip(nil) }
    }
}
