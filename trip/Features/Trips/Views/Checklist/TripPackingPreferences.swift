import TripLocalization
import SwiftUI
import TripDomain

struct TripPackingPreferences: View {
    let controller: TripController
    let tripID: UUID

    var body: some View {
        Section {
            TextField(TripText.preferencesEGCarryOnOnly.resource, text: controller.packingPreferences, axis: .vertical)
                .lineLimit(2...4).disabled(controller.model.packing.isGenerating)
            if let reason = controller.model.packing.unavailableReason {
                Label(reason, systemImage: "sparkles").foregroundStyle(.secondary)
            } else {
                TripPackingGenerateButton(tripID: tripID, controller: controller)
            }
            Button(TripText.addTravelEssentials.resource, systemImage: "suitcase.rolling") {
                controller.addChecklistTemplate(.essentials, tripID: tripID)
                controller.refreshPacking(tripID)
            }
            .disabled(controller.model.library.trip(tripID)?.canAddChecklistItem != true)
        } footer: {
            Text(TripText.generatedOnThisDeviceUsingTripDurationActivityCategories.resource)
        }
    }
}

#if DEBUG
#Preview("Packing preferences · unavailable") {
    let model = TripPackingPreview.planner(unavailable: true)
    Form { TripPackingPreferences(controller: TripController(model: model), tripID: model.library.trips[0].id) }
}
#endif
