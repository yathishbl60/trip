import MapKit
import SwiftUI

@MainActor enum CameraRestorationChecks {
    static func run() throws {
        let camera = MapCamera(centerCoordinate: Coordinate.bangkok.location, distance: 4_200, heading: 32, pitch: 50)
        guard let encoded = MapCameraSnapshot(camera).encoded else { throw CheckFailure(description: "Valid camera failed to encode") }
        let state = MapCameraRestorationModel()
        state.record(camera)
        try require(state.snapshot.isEmpty, "Initial feedback overwrote restoration before it was read")
        try require(state.restore(encoded) == camera, "Restoration lost camera perspective")
        try require(state.restore(encoded) == nil, "Restoration ran twice")
        state.record(camera)
        try require(MapCameraSnapshot.decode(state.snapshot) == MapCameraSnapshot(camera), "Settled camera did not persist")
        try require(MapCameraRestorationModel().snapshot.isEmpty, "Windows shared camera storage")
        try navigationWins(encoded)
        try invalidSnapshots()
        print("PASS: camera restoration validates input and yields to newer navigation")
    }

    private static func navigationWins(_ value: String) throws {
        let camera = CameraModel()
        camera.focus(Coordinate(latitude: 48.86, longitude: 2.35))
        let explicit = camera.currentCamera
        try require(camera.restoration.restore(value) == nil && camera.currentCamera == explicit,
                    "Saved area overrode an explicit place")
    }

    private static func invalidSnapshots() throws {
        let values = ["", "not-json", "{}", String(repeating: "x", count: 2_000),
                      #"{"center":{"latitude":91,"longitude":0},"distance":1000,"heading":0,"pitch":0}"#,
                      #"{"center":{"latitude":13,"longitude":100},"distance":-1,"heading":0,"pitch":0}"#]
        for value in values {
            try require(MapCameraSnapshot.decode(value)?.camera == nil, "Invalid persisted camera was accepted")
        }
    }
}
