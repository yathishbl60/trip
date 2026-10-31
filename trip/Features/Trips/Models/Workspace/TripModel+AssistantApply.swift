import TripLocalization
import Foundation
import TripDomain

extension TripModel {
    func assistantApplyIssue(_ id: UUID) -> String? {
        guard presentation.assistantTripID == id, let source = library.trip(id),
              assistant.canSaveDraft, let revision = assistant.revision else { return TripText.createADraftFirst.text }
        if tracking.isBusy || (tracking.runtime?.journey?.tripID == id && tracking.runtime?.journey?.isActive == true) {
            return TripText.endDayTrackingBeforeChangingTheItinerary.text
        }
        return revision.issue(in: source, draft: assistant.days)
    }

    func applyAssistantPlan(_ id: UUID) {
        assistant.isConfirmingApply = false
        if let issue = assistantApplyIssue(id) { assistant.error = issue; return }
        guard let source = library.trip(id), let revision = assistant.revision else { return }
        let draft = assistant.daysPreservingDetails(from: source)
        guard library.update(id, edit: { revision.apply(draft, to: &$0) }) else {
            assistant.error = TripText.couldnTUpdateThisTripTryAgain.text
            return
        }
        dismissAssistant()
        feedback.show(TripText.itineraryUpdated.text)
    }

    func refineAssistant(_ choice: TripPlanRefinement, tripID: UUID) {
        guard presentation.assistantTripID == tripID, let trip = library.trip(tripID) else { return }
        assistant.refine(choice, source: trip)
    }

    func findAssistantPlaces(_ id: UUID) {
        guard presentation.assistantTripID == id, let day = library.trip(id)?.days.first else { return }
        beginSavedPlaces(dayID: day.id, tripID: id)
    }
}
