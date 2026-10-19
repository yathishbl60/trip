#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

struct DirectionsModePicker: View {
    let controller: DirectionsController
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize.isAccessibilitySize || controller.model.presentation.usesLargeText {
            picker.pickerStyle(.menu)
        } else {
            picker.pickerStyle(.segmented).labelStyle(.iconOnly)
        }
    }

    private var picker: some View {
        Picker(TripText.travelMode.resource, selection: controller.mode) {
            ForEach(controller.model.availableModes) { mode in
                Label(mode.title, systemImage: mode.symbol).tag(mode)
            }
        }
        .accessibilityHint(TripText.changesTheRouteAndEstimatedTravelTime.resource)
    }
}

#if DEBUG
#Preview("All travel modes", traits: .sizeThatFitsLayout) {
    DirectionsModePicker(controller: DirectionsController(model: DirectionsPreviewFixtures.ready())).padding()
}
#Preview("Travel mode · maximum text", traits: .sizeThatFitsLayout) {
    Form { DirectionsModePicker(controller: DirectionsController(model: DirectionsPreviewFixtures.ready())) }
        .frame(width: 280).dynamicTypeSize(.accessibility5)
}
#endif
#endif
