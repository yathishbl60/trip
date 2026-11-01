import TripLocalization
import SwiftUI
import TripDomain

struct TripPackingForm: View {
    let tripID: UUID
    let controller: TripController

    var body: some View {
        Form {
            if controller.model.library.trip(tripID) != nil {
                TripPackingPreferences(controller: controller, tripID: tripID)
                if let error = controller.model.packing.error {
                    Section { Label(error, systemImage: "exclamationmark.circle").foregroundStyle(.secondary) }
                }
                TripPackingReview(controller: controller)
            } else { ContentUnavailableView(TripText.tripUnavailable.resource, systemImage: "suitcase.rolling") }
        }
    }
}

#if DEBUG
#Preview("Packing form · retry") {
    let model = TripPackingPreview.planner()
    model.packing.error = "Couldn’t create a packing list. Try again or use travel essentials."
    return TripPackingForm(tripID: model.library.trips[0].id, controller: TripController(model: model))
}
#endif
