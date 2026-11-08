import SwiftUI
import TripDomain

extension TripChecklistController {
    func packingPresentation(_ tripID: UUID) -> Binding<Bool> {
        let sessionID = model.packingSession?.id
        return Binding(get: { model.packingSession?.tripID == tripID }, set: { presented in
            if !presented, model.packingSession?.id == sessionID { model.dismissPacking() }
        })
    }

    var packingPreferences: Binding<String> {
        Binding(get: { model.packing.preferences }, set: model.packing.setPreferences)
    }

    func packingSelection(_ suggestion: TripPackingSuggestion) -> Binding<Bool> {
        Binding(get: { model.packing.selected.contains(suggestion.id) }, set: { selected in
            if selected { model.packing.selected.insert(suggestion.id) }
            else { model.packing.selected.remove(suggestion.id) }
        })
    }

    func openPacking(_ tripID: UUID) { model.openPacking(tripID) }
    func dismissPacking() { model.dismissPacking() }
    func cancelPacking() { model.cancelPacking() }
    func savePacking(_ tripID: UUID) { model.savePacking(tripID) }
    func generatePacking(_ tripID: UUID) { model.generatePacking(tripID) }

    func refreshPacking(_ tripID: UUID) { model.refreshPacking(tripID) }
    func packingSceneChanged(_ phase: ScenePhase) {
        if phase == .active { model.packing.refreshAvailability() }
        else { model.packing.cancel() }
    }
}
