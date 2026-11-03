import MapKit
import SwiftUI
import Observation
import Synchronization

@MainActor enum CameraFeedbackChecks {
    static func run() throws {
        let camera = CameraModel()
        let updates = ObservationCounter()
        observe(camera, updates)
        for frame in 0..<240 { camera.receivePosition(position(frame)) }
        try require(updates.count.withLock { $0 } == 0, "MapKit feedback invalidated its own annotation tree")
        let longitude = camera.position.camera?.centerCoordinate.longitude ?? 0
        try require(abs(longitude - 100.50239) < 0.0000001, "Latest feedback not retained")
        camera.focus(.bangkok)
        try require(updates.count.withLock { $0 } == 1, "Programmatic camera move did not notify SwiftUI")
        observe(camera, updates)
        camera.move(to: .district)
        try require(updates.count.withLock { $0 } == 2, "Zoom command did not notify SwiftUI")
        try CameraMovementChecks.run()
        print("PASS: 240 camera feedback writes, 0 observation invalidations; programmatic moves still notify")
    }

    static func position(_ frame: Int) -> MapCameraPosition {
        .camera(MapCamera(centerCoordinate: Coordinate(latitude: 13.75, longitude: 100.5 + Double(frame) * 0.00001).location,
                          distance: 8_000))
    }

    static func observe(_ camera: CameraModel, _ updates: ObservationCounter) {
        withObservationTracking {
            _ = camera.position
        } onChange: {
            updates.count.withLock { $0 += 1 }
        }
    }
}

nonisolated final class ObservationCounter: Sendable {
    let count = Mutex(0)
}
