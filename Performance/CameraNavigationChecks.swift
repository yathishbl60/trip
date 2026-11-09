import CoreLocation
import MapKit
import SwiftUI

@MainActor enum CameraNavigationChecks {
    static func run() throws {
        let model = CameraModel()
        let origin = model.currentCamera
        model.exploreIn3D()
        try require(model.currentCamera.pitch == 50 && model.canGoBack, "3D camera did not retain the previous area")
        model.goBack()
        try require(model.currentCamera == origin && !model.canGoBack, "Return did not restore the full camera")
        model.resetOrientation()
        try require(!model.canGoBack, "No-op orientation replaced camera history")
        model.focus(CheckFixtures.place("focus").coordinate)
        try require(model.currentCamera.distance == 1_400, "Focus did not move close enough")
        model.goBack()
        try require(model.currentCamera == origin, "Focus lost the previous camera")
        try motionGate()
        try contextualControls()
        try dotSelection()
        try measuredDotSelection()
        try CameraRestorationChecks.run()
        print("PASS: camera return, dot selection zoom, perspective, no-op commands, and accumulated pan gating")
    }

    private static func dotSelection() throws {
        let model = CameraModel()
        var origin = model.currentCamera
        origin.distance = ZoomLevel.region.distance
        origin.heading = 37
        origin.pitch = 45
        model.position = .camera(origin)
        let coordinate = CheckFixtures.place("dot").coordinate
        model.zoomToAnnotation(coordinate)
        let selected = model.currentCamera
        try require(selected.distance == ZoomLevel.district.distance, "Dot selection did not reach icon/image zoom")
        try require(selected.centerCoordinate.latitude == coordinate.latitude && selected.heading == 37 && selected.pitch == 45,
                    "Dot selection lost its place or camera perspective")
        model.goBack()
        try require(model.currentCamera == origin, "Dot selection lost the previous camera")
        model.focus(coordinate)
        model.zoomToAnnotation(coordinate)
        try require(model.currentCamera.distance == 700, "A crowded close-up dot zoomed outward")
    }

    private static func contextualControls() throws {
        let model = CameraModel()
        try require(!model.canResetOrientation && !model.isTilted, "Unneeded controls at startup")
        model.exploreIn3D()
        try require(model.isTilted && model.canResetOrientation, "3D has no reset action")
        model.goBack()
        try require(!model.isTilted && !model.canResetOrientation, "Return kept obsolete orientation controls")
        var camera = model.currentCamera
        camera.heading = 360
        model.updateNavigationState(camera)
        try require(!model.canResetOrientation, "Full rotation incorrectly requires reset")
        camera.heading = 90
        model.updateNavigationState(camera)
        try require(model.canResetOrientation, "Settled rotation has no reset action")
    }

    private static func measuredDotSelection() throws {
        let model = CameraModel()
        var camera = model.currentCamera
        camera.distance = ZoomLevel.region.distance
        camera.pitch = 70
        model.position = .camera(camera)
        model.size = CGSize(width: 400, height: 800)
        model.groundScale = CameraGroundScale(metersPerPoint: 2_000, camera: camera, viewport: model.size)
        model.zoomToAnnotation(.bangkok)
        let scale = 2_000 * model.currentCamera.distance / camera.distance
        try require(ZoomLevel.resolve(metersPerPoint: scale, previous: .region) != .region,
                    "A pitched or short viewport kept the selected annotation as a dot")
    }

    private static func motionGate() throws {
        let camera = CameraModel().currentCamera
        let viewport = CGSize(width: 400, height: 800)
        let rect = CGRect(origin: .zero, size: viewport)
        let origin = CameraSample(camera, rect: rect)
        let small = CameraSample(camera, rect: rect.offsetBy(dx: 10, dy: 10))
        let large = CameraSample(camera, rect: rect.offsetBy(dx: 24, dy: 0))
        try require(!small.differs(from: origin, viewport: viewport), "Small pan should retain the current layout")
        try require(large.differs(from: origin, viewport: viewport), "Accumulated pan should replenish markers")
        var rotated = camera
        rotated.heading = 1
        let rotation = CameraSample(rotated, rect: rect)
        try require(rotation.differs(from: origin, viewport: viewport), "Pan gating suppressed a rotation")
        rotated.distance *= 0.98
        rotated.heading = 0
        try require(CameraSample(rotated, rect: rect).differs(from: origin, viewport: viewport), "Pan gating suppressed zoom")
    }
}
