import MapKit
import SwiftUI
import TripDomain

@MainActor final class MapBrowseContext {
    private var inspectionCamera: MapCamera?
    private var returningCamera: MapCamera?

    func inspect(from camera: MapCamera) {
        if inspectionCamera == nil { inspectionCamera = camera }
    }

    func returnCamera() -> MapCamera? {
        returningCamera = inspectionCamera
        inspectionCamera = nil
        return returningCamera
    }

    func reset() {
        inspectionCamera = nil
        returningCamera = nil
    }

    func accepts(_ camera: MapCamera) -> Bool {
        guard let target = returningCamera else { return true }
        let distance = Coordinate(camera.centerCoordinate).distance(to: Coordinate(target.centerCoordinate))
        guard distance < max(5, target.distance * 0.01),
              abs(camera.distance - target.distance) < max(1, target.distance * 0.01) else { return false }
        returningCamera = nil
        return true
    }
}
