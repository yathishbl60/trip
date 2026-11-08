#if DEBUG
import Foundation
import TripDomain

@MainActor enum TripPackingPreview {
    static func planner(unavailable: Bool = false) -> TripChecklistModel {
        let model = PreviewFixtures.checklist()
        model.openPacking(model.library.trips[0].id)
        model.packing.unavailableReason = unavailable ? "Apple Intelligence isn’t available. Travel essentials still works." : nil
        if !unavailable {
            model.packing.suggestions = ["Comfortable walking shoes", "Lightweight day bag", "Reusable water bottle"]
                .map(TripPackingSuggestion.init)
            model.packing.selected = Set(model.packing.suggestions.map(\.id))
        }
        return model
    }
}
#endif
