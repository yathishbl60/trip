import MapKit
import SwiftUI
import Observation

@MainActor @Observable final class MapCameraRestorationModel {
    private(set) var snapshot = ""
    @ObservationIgnored var hasNavigation = false
    @ObservationIgnored private var attempted = false

    func restore(_ value: String) -> MapCamera? {
        guard !attempted else { return nil }
        attempted = true
        guard !hasNavigation else { return nil }
        return MapCameraSnapshot.decode(value)?.camera
    }

    func record(_ camera: MapCamera) {
        guard attempted, let value = MapCameraSnapshot(camera).encoded, value != snapshot else { return }
        snapshot = value
    }
}
