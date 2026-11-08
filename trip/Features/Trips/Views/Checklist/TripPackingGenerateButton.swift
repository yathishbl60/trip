import TripLocalization
import SwiftUI
import TripDomain

struct TripPackingGenerateButton: View {
    let tripID: UUID
    let controller: TripChecklistController

    var body: some View {
        if controller.model.packing.isGenerating {
            HStack {
                ProgressView().accessibilityLabel(TripText.generatingPackingSuggestions.resource)
                Text(TripText.creatingSuggestions.resource)
                Spacer()
                Button(TripText.stop.resource, action: controller.cancelPacking)
            }
        } else {
            Button(TripText.generateSuggestions.resource, systemImage: "sparkles") { controller.generatePacking(tripID) }
        }
    }
}

#if DEBUG
#Preview("Generate packing · loading") {
    let model = TripPackingPreview.planner()
    model.packing.isGenerating = true
    return Form { TripPackingGenerateButton(tripID: model.library.trips[0].id, controller: TripChecklistController(model: model)) }
}
#endif
