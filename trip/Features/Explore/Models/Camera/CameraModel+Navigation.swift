#if !TRIP_STANDALONE
import TripDomain
#endif
import MapKit
import SwiftUI

extension CameraModel {
    var canGoBack: Bool { previousCamera != nil }
    var canResetOrientation: Bool { isTilted || isRotated }

    var currentCamera: MapCamera {
        if let camera = position.camera { return camera }
        return sampledCamera
    }

    /// Native feedback describes the visible camera while position may still be its animation target.
    var sampledCamera: MapCamera {
        if let sample {
            return MapCamera(centerCoordinate: sample.center.location, distance: sample.distance,
                             heading: sample.heading, pitch: sample.pitch)
        }
        if let camera = position.camera { return camera }
        return MapCamera(centerCoordinate: configuration.validCenter.location, distance: configuration.validDistance)
    }

    func navigate(to camera: MapCamera) {
        restoration.hasNavigation = true
        guard camera != currentCamera else { return }
        previousCamera = currentCamera
        updateNavigationState(camera)
        transition(to: camera)
    }

    func goBack() {
        guard let previousCamera else { return }
        self.previousCamera = nil
        updateNavigationState(previousCamera)
        transition(to: previousCamera)
    }

    /// Publish coarse toolbar state only at navigation and gesture boundaries.
    func updateNavigationState(_ camera: MapCamera) {
        let tolerance = CameraNavigationPolicy.orientationTolerance
        let tilted = camera.pitch > tolerance
        let heading = camera.heading.truncatingRemainder(dividingBy: 360)
        let rotated = abs(heading) > tolerance && abs(heading) < 360 - tolerance
        if isTilted != tilted { isTilted = tilted }
        if isRotated != rotated { isRotated = rotated }
    }

    func resetOrientation() {
        var camera = currentCamera
        camera.heading = 0
        camera.pitch = 0
        navigate(to: camera)
    }

    func exploreIn3D() {
        var camera = currentCamera
        camera.pitch = CameraNavigationPolicy.explorationPitch
        navigate(to: camera)
    }

    func exploreIn3D(at coordinate: Coordinate) {
        var camera = currentCamera
        camera.centerCoordinate = coordinate.location
        camera.distance = CameraNavigationPolicy.explorationDistance
        camera.pitch = CameraNavigationPolicy.explorationPitch
        navigate(to: camera)
    }
}
