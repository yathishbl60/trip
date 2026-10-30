import TripLocalization
import SwiftUI

struct MapNavigationOptions: View {
    let controller: MapNavigationController

    var body: some View {
        Group {
            if !controller.model.camera.isTilted {
                Button(TripText.viewIn3D.resource, systemImage: "cube", action: controller.exploreIn3D)
            }
            if controller.model.camera.canResetOrientation {
                Button(TripText.faceNorthIn2D.resource, systemImage: "location.north.line", action: controller.resetOrientation)
            }
        }
    }
}

#if DEBUG
#Preview("Navigation · starting area", traits: .sizeThatFitsLayout) {
    MapNavigationOptions(controller: MapNavigationController(model: PreviewFixtures.explore())).padding()
}
#Preview("Navigation · return available", traits: .sizeThatFitsLayout) {
    MapNavigationOptions(controller: MapNavigationController(model: PreviewFixtures.focused()))
        .padding().preferredColorScheme(.dark)
}
#endif
