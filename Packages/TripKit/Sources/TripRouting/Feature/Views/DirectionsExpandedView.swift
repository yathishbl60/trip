#if os(iOS) || os(visionOS)
import SwiftUI
import TripDomain

struct DirectionsExpandedView: View {
    let controller: DirectionsController

    var body: some View {
        List {
            Section { DirectionsModePicker(controller: controller) }
            Section { DirectionsResultsView(controller: controller) }
            Section { DirectionsEndpointsView(controller: controller) }
        }
        .scrollContentBackground(.hidden)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
        #if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        #endif
    }
}

#if DEBUG
#Preview("Expanded directions") {
    DirectionsExpandedView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready()))
}
#Preview("Expanded directions · dark") {
    DirectionsExpandedView(controller: DirectionsController(model: DirectionsPreviewFixtures.ready()))
        .preferredColorScheme(.dark)
}
#Preview("Directions failure · standard height") {
    DirectionsExpandedView(controller: DirectionsController(model: DirectionsPreviewFixtures.unavailable()))
        .frame(height: 400)
}
#endif
#endif
