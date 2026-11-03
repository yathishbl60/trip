import CoreGraphics
import MapKit
import SwiftUI

@MainActor enum CameraGroundScaleChecks {
    static func run() throws {
        try preferredStages()
        try calibratedNavigation()
        try advancingFeedback()
        try incompatibleGeometry()
        try invalidMeasurements()
        print("PASS: calibrated zoom stages, paired projection measurements, and geometry fallback")
    }

    private static func preferredStages() throws {
        for target in ZoomLevel.allCases {
            for origin in ZoomLevel.allCases {
                for margin in [0.02, 0.12, 0.35] {
                    let resolved = ZoomLevel.resolve(metersPerPoint: target.preferredMetersPerPoint,
                                                     previous: origin, hysteresis: margin)
                    try require(resolved == target, "Camera target landed inside another stage's hysteresis")
                }
            }
        }
    }

    private static func calibratedNavigation() throws {
        let model = calibratedModel()
        let origin = model.currentCamera
        for level in ZoomLevel.allCases {
            model.move(to: level)
            let target = model.currentCamera
            let scale = 500 * target.distance / origin.distance
            try require(ZoomLevel.resolve(metersPerPoint: scale, previous: .region) == level,
                        "Calibrated menu choice did not reach its annotation stage")
            try require(target.pitch == origin.pitch && target.heading == origin.heading,
                        "Calibrated zoom changed perspective")
            model.goBack()
            try require(model.currentCamera == origin, "Calibrated zoom lost camera history")
        }
    }

    private static func advancingFeedback() throws {
        let model = calibratedModel()
        let expected = model.groundScale!.distance(for: .district, camera: model.currentCamera, viewport: model.size)!
        var latest = model.currentCamera
        latest.distance *= 4
        model.recordMovement(CameraSample(latest, rect: CGRect(origin: .zero, size: model.size)))
        model.receivePosition(.camera(latest))
        model.zoomToAnnotation(.bangkok)
        try require(abs(model.currentCamera.distance - expected) < 0.001,
                    "Dot selection paired an older scale with a newer camera distance")
    }

    private static func incompatibleGeometry() throws {
        let model = calibratedModel()
        model.size.width += 100
        model.move(to: .district)
        try require(model.currentCamera.distance == ZoomLevel.district.distance, "Resized map reused an old scale")
        model.goBack()
        model.size.width -= 100
        var camera = model.currentCamera
        camera.pitch = 0
        model.position = .camera(camera)
        model.move(to: .street)
        try require(model.currentCamera.distance == ZoomLevel.street.distance, "Changed pitch reused an old scale")
    }

    private static func invalidMeasurements() throws {
        let model = calibratedModel()
        for value in [Double.nan, .infinity, -.infinity, 0, -1] {
            try require(CameraGroundScale(metersPerPoint: value, camera: model.currentCamera, viewport: model.size) == nil,
                        "Invalid ground scale created a camera calibration")
        }
        try require(CameraGroundScale(metersPerPoint: 1, camera: model.currentCamera, viewport: .zero) == nil,
                    "An unlaid-out viewport created a camera calibration")
    }

    private static func calibratedModel() -> CameraModel {
        let model = CameraModel()
        model.reduceMotion = true
        model.size = CGSize(width: 800, height: 300)
        let camera = MapCamera(centerCoordinate: Coordinate.bangkok.location, distance: 80_000, heading: 37, pitch: 70)
        model.position = .camera(camera)
        model.groundScale = CameraGroundScale(metersPerPoint: 500, camera: camera, viewport: model.size)
        return model
    }
}
