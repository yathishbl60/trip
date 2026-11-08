import TripLocalization
import SwiftUI

struct TripPackingReview: View {
    let controller: TripChecklistController

    var body: some View {
        if !controller.model.packing.suggestions.isEmpty {
            Section {
                ForEach(controller.model.packing.suggestions) { item in
                    Toggle(item.title, isOn: controller.packingSelection(item))
                }
            } header: { Text(TripText.chooseWhatToAdd.resource) } footer: {
                Text(TripText.onlySelectedItemsAreAddedExistingChecklistItemsAnd.resource)
            }
            .disabled(controller.model.packing.isGenerating)
        }
    }
}

#if DEBUG
#Preview("Packing selection · long text") {
    let model = TripPackingPreview.planner()
    Form { TripPackingReview(controller: TripChecklistController(model: model)) }.dynamicTypeSize(.accessibility2)
}
#endif
