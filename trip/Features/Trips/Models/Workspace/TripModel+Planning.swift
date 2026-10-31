import Foundation
import TripDomain
import TripLocalization

extension TripModel {
    func beginPlanning(dayID: UUID, tripID: UUID, place: Place? = nil, index: Int? = nil) {
        guard let trip = library.trip(tripID), let day = trip.days.first(where: { $0.id == dayID }) else { return }
        if let place, !canAdd(place, to: day.stops, container: .day) { return }
        presentation.planning = TripPlanningDraft(trip: trip, day: day, place: place, index: index)
    }

    func planningIssue(_ draft: TripPlanningDraft) -> String? {
        guard let trip = library.trip(draft.trip.id), draft.matches(trip) else { return TripText.planningChanged.text }
        if tracking.isBusy { return TripText.waitForTheVisitUpdateToFinish.text }
        if let journey = tracking.runtime?.journey, journey.isActive,
           journey.tripID == trip.id, journey.dayID == draft.day.id {
            return TripText.endDayTrackingToSuggestANewOrder.text
        }
        return nil
    }

    func applyPlanning(_ draft: TripPlanningDraft) {
        guard presentation.planning?.id == draft.id, draft.hasChanges else { return }
        if let issue = planningIssue(draft) { draft.notice = issue; return }
        let saved = library.update(draft.trip.id) { trip in
            guard draft.matches(trip), let index = trip.days.firstIndex(where: { $0.id == draft.day.id }) else { return false }
            trip.days[index] = draft.day
            return true
        }
        guard saved else { draft.notice = TripText.planningChanged.text; return }
        closePlanning(draft.id)
        if draft.isInsertion { dismissDestination() }
        feedback.show(draft.isInsertion ? TripText.addedToValueValue(draft.trip.title, draft.day.title).text
                                       : TripText.planningSaved.text)
    }

    func closePlanning(_ id: UUID) {
        guard let draft = presentation.planning, draft.id == id else { return }
        draft.routes.invalidate()
        presentation.planning = nil
    }

    func reviewPlacement(_ place: Place, dayID: UUID, tripID: UUID) {
        guard let day = library.trip(tripID)?.days.first(where: { $0.id == dayID }) else { return }
        let index = TripPlaceInsertion.best(for: place, in: day)?.index
        beginPlanning(dayID: dayID, tripID: tripID, place: place, index: index)
    }
}
