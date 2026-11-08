import TripLocalization
import TripDomain
import Foundation

extension TripChecklistModel {
    func openPacking(_ tripID: UUID) {
        guard let plan = library.trip(tripID), plan.canAddChecklistItem else { return }
        packing.prepare(plan)
        packingSession = TripPackingSession(tripID: tripID)
    }

    func dismissPacking() {
        packing.cancel()
        packingSession = nil
    }

    func savePacking(_ tripID: UUID) {
        guard packingSession?.tripID == tripID, !packing.isGenerating,
              let plan = library.trip(tripID), packing.context == TripPackingContext(plan) else { return }
        let titles = packing.selectedTitles
        let space = TripLimits.checklistItems - plan.checklist.count
        guard TripChecklistEditing.missing(titles, from: plan.checklist).count <= space else {
            packing.error = TripText.yourChecklistHasRoomForValueMoreItemsSelect(TripText.number(max(0, space))).text
            return
        }
        let added = library.update(tripID) { TripChecklistEditing.append(titles, to: &$0) > 0 }
        if added { dismissPacking(); environment.showFeedback(TripText.addedToYourChecklist.text) }
        else { packing.refresh(plan); packing.error = TripText.theseItemsAreAlreadyAddedOrYourChecklistIs2.text }
    }

    func cancelPacking() { packing.cancel() }
    func setPackingPreferences(_ value: String) { packing.setPreferences(value) }

    func generatePacking(_ tripID: UUID) {
        guard let plan = library.trip(tripID) else { return }
        packing.generate(plan)
    }

    func refreshPacking(_ tripID: UUID) { packing.refresh(library.trip(tripID)) }
}
