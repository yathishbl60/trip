#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

struct DirectionsToolbar: ToolbarContent {
    let controller: DirectionsController

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(TripText.options.resource, systemImage: "slider.horizontal.3", action: controller.showOptions)
                .accessibilityValue(controller.model.optionsTitle)
        }
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .close, action: controller.dismiss)
                .accessibilityLabel(TripText.closeDirections.resource)
        }
    }
}

#if DEBUG
#Preview("Directions · native toolbar") {
    NavigationStack {
        Color.clear.navigationTitle("Directions").navigationBarTitleDisplayMode(.inline)
            .toolbar { DirectionsToolbar(controller: DirectionsController(model: DirectionsPreviewFixtures.ready())) }
    }
}
#Preview("Directions toolbar · large text, dark") {
    NavigationStack {
        Color.clear.navigationTitle("Directions").navigationBarTitleDisplayMode(.inline)
            .toolbar { DirectionsToolbar(controller: DirectionsController(model: DirectionsPreviewFixtures.ready())) }
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
#endif
