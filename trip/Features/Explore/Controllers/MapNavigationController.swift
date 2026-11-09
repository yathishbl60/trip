import MapEngine
import MapKit
import SwiftUI

@MainActor struct MapNavigationController {
    let model: ExploreModel

    func goBack() { navigate(model.camera.goBack) }
    func resetOrientation() { navigate(model.camera.resetOrientation) }
    func exploreIn3D() { navigate(model.camera.exploreIn3D) }

    func restore(_ value: String) {
        guard let camera = model.camera.restoration.restore(value) else { return }
        model.camera.position = .camera(camera)
        model.camera.updateNavigationState(camera)
    }

    private func navigate(_ action: () -> Void) {
        model.filters.isPresented = false
        action()
    }
}
