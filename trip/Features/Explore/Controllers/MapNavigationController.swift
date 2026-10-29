import MapEngine
import SwiftUI

@MainActor struct MapNavigationController {
    let model: ExploreModel

    func goBack() { navigate(model.camera.goBack) }
    func resetOrientation() { navigate(model.camera.resetOrientation) }
    func exploreIn3D() { navigate(model.camera.exploreIn3D) }

    private func navigate(_ action: () -> Void) {
        model.filters.isPresented = false
        action()
    }
}
