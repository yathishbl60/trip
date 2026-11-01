import SwiftUI
import TripDomain

extension TripController {
    func packingPresentation(_ tripID: UUID) -> Binding<Bool> {
        Binding(get: { model.presentation.packingTripID == tripID }, set: { if !$0 { model.dismissPacking() } })
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
    func cancelPacking() { model.packing.cancel() }
    func savePacking(_ tripID: UUID) { model.savePacking(tripID) }
    func generatePacking(_ tripID: UUID) {
        guard let plan = model.library.trip(tripID) else { return }
        model.packing.generate(plan)
    }

    func refreshPacking(_ tripID: UUID) { model.packing.refresh(model.library.trip(tripID)) }
    func packingSceneChanged(_ phase: ScenePhase) {
        if phase == .active { model.packing.refreshAvailability() }
        else { model.packing.cancel() }
    }
}
