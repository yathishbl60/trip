import TripLocalization
import TripDomain
import Foundation

extension TripModel {
    func openPacking(_ tripID: UUID) {
        guard let plan = library.trip(tripID), plan.canAddChecklistItem else { return }
        packing.prepare(plan)
        presentation.packingTripID = tripID
    }

    func dismissPacking() {
        packing.cancel()
        presentation.packingTripID = nil
    }

    func savePacking(_ tripID: UUID) {
        guard presentation.packingTripID == tripID, !packing.isGenerating,
              let plan = library.trip(tripID), packing.context == TripPackingContext(plan) else { return }
        let titles = packing.selectedTitles
        let space = TripLimits.checklistItems - plan.checklist.count
        guard TripChecklistEditing.missing(titles, from: plan.checklist).count <= space else {
            packing.error = TripText.yourChecklistHasRoomForValueMoreItemsSelect(TripText.number(max(0, space))).text
            return
        }
        let added = library.update(tripID) { TripChecklistEditing.append(titles, to: &$0) > 0 }
        if added { dismissPacking(); feedback.show(TripText.addedToYourChecklist.text) }
        else { packing.refresh(plan); packing.error = TripText.theseItemsAreAlreadyAddedOrYourChecklistIs2.text }
    }
}
