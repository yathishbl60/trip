import TripLocalization
import Foundation
import TripDomain

extension TripModel {
    func stopOrderIssue(day: TripDay, tripID: UUID) -> String? {
        guard (3...TripLimits.stops).contains(day.stops.count) else { return TripText.addAtLeastThreePlacesFirst.text }
        guard day.stops.allSatisfy({ $0.place.coordinate.isValid }) else { return TripText.aPlaceIsMissingItsMapLocation.text }
        if let journey = tracking.runtime?.journey,
           journey.isActive, journey.tripID == tripID, journey.dayID == day.id {
            return TripText.endDayTrackingToSuggestANewOrder.text
        }
        return tracking.isBusy ? TripText.waitForTheVisitUpdateToFinish.text : nil
    }

    func beginStopOrder(dayID: UUID, tripID: UUID) {
        guard let day = library.trip(tripID)?.days.first(where: { $0.id == dayID }) else { return }
        if let issue = stopOrderIssue(day: day, tripID: tripID) { presentation.notice = issue; return }
        presentation.notice = nil
        presentation.stopOrder = TripStopOrderModel(tripID: tripID, day: day, service: stopOrdering)
    }

    func applyStopOrder(_ draft: TripStopOrderModel) {
        guard presentation.stopOrder?.id == draft.id, let proposal = draft.proposal,
              let current = library.trip(draft.tripID)?.days.first(where: { $0.id == draft.day.id }) else { return }
        if let issue = stopOrderIssue(day: current, tripID: draft.tripID) { draft.notice = issue; return }
        guard library.updateDay(current.id, in: draft.tripID, edit: { proposal.apply(to: &$0) }) else {
            draft.notice = TripText.thisDayChangedCloseAndRequestANewSuggestion.text
            return
        }
        presentation.stopOrder = nil
        feedback.show(TripText.updatedStopOrder.text)
    }

    func canApplyStopOrder(_ draft: TripStopOrderModel) -> Bool {
        guard let day = library.trip(draft.tripID)?.days.first(where: { $0.id == draft.day.id }),
              let proposal = draft.proposal else { return false }
        return proposal.hasImprovement && proposal.matches(day) && stopOrderIssue(day: day, tripID: draft.tripID) == nil
    }
}
