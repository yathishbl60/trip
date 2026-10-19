#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

struct DirectionsMapsButton: View {
    let controller: DirectionsController
    @Environment(\.openURL) private var openURL
    @State private var handoffFailed = false

    var body: some View {
        Button(TripText.openInMaps.resource, systemImage: "arrow.up.forward.app") {
            controller.openMaps(using: openURL) { handoffFailed = !$0 }
        }
            .buttonStyle(prominentStyle)
            .tint(controller.model.environment.appearance.actionTint)
            .controlSize(.large)
            .disabled(controller.model.mapsURL == nil)
            .accessibilityLabel(TripText.openInAppleMaps.resource)
            .accessibilityHint(TripText.chooseARouteAndStartNavigationInAppleMaps.resource)
            .alert(TripText.unableToOpenMaps.resource, isPresented: $handoffFailed) {
                Button(TripText.ok.resource, role: .cancel) {}
            } message: { Text(TripText.appleMapsCouldnTOpenThisRouteTryAgain.resource) }
    }

    private var prominentStyle: some PrimitiveButtonStyle {
        #if os(visionOS)
        BorderedProminentButtonStyle()
        #else
        GlassProminentButtonStyle()
        #endif
    }
}

#if DEBUG
#Preview("Continue in Maps", traits: .sizeThatFitsLayout) {
    DirectionsMapsButton(controller: DirectionsController(model: DirectionsPreviewFixtures.ready())).padding()
}
#Preview("Maps handoff · large text, dark", traits: .sizeThatFitsLayout) {
    DirectionsMapsButton(controller: DirectionsController(model: DirectionsPreviewFixtures.ready()))
        .padding().dynamicTypeSize(.accessibility3).preferredColorScheme(.dark)
}
#Preview("Maps handoff · rejected launch, local", traits: .sizeThatFitsLayout) {
    DirectionsMapsButton(controller: DirectionsController(model: DirectionsPreviewFixtures.ready()))
        .environment(\.openURL, OpenURLAction { _ in .discarded }).padding()
}
#endif
#endif
