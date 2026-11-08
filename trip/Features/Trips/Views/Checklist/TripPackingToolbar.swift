import TripLocalization
import SwiftUI
import TripDomain

struct TripPackingToolbar: ToolbarContent {
    let tripID: UUID
    let controller: TripChecklistController

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(TripText.cancel.resource, action: controller.dismissPacking)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(TripText.addSelected.resource) { controller.savePacking(tripID) }
                .disabled(controller.model.packing.selected.isEmpty || controller.model.packing.isGenerating
                          || controller.model.trip(tripID) == nil)
        }
    }
}

#if DEBUG
#Preview("Packing actions") {
    let model = TripPackingPreview.planner()
    NavigationStack {
        Text("Review suggestions").toolbar {
            TripPackingToolbar(tripID: model.library.trips[0].id, controller: TripChecklistController(model: model))
        }
    }
}
#endif
