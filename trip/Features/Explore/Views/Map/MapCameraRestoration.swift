import SwiftUI

struct MapCameraRestoration: ViewModifier {
    let controller: MapNavigationController
    @SceneStorage("explore.camera") private var snapshot = ""

    func body(content: Content) -> some View {
        content
            .onAppear { controller.restore(snapshot) }
            .onChange(of: controller.model.camera.restoration.snapshot) {
                snapshot = controller.model.camera.restoration.snapshot
            }
    }
}

#if DEBUG
#Preview("Camera restoration · local scene") {
    Text("Explore").modifier(MapCameraRestoration(controller: MapNavigationController(model: PreviewFixtures.explore())))
}
#endif
