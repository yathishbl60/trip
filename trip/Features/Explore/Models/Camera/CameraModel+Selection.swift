#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import CoreGraphics
import Foundation
import MapKit
import SwiftUI

extension CameraModel {
    var canFrameSelection: Bool {
        guard let sample else { return false }
        guard let intended = position.camera else { return true }
        let tolerance = CameraNavigationPolicy.framingTolerance(at: sample.distance)
        return abs(intended.distance - sample.distance) < tolerance
            && Coordinate(intended.centerCoordinate).distance(to: sample.center) < tolerance
    }

    func zoomToAnnotation(_ coordinate: Coordinate) {
        var camera = currentCamera
        camera.centerCoordinate = coordinate.location
        let target = groundScale?.distance(for: .district, camera: camera, viewport: size)
            ?? ZoomLevel.district.distance
        camera.distance = CameraNavigationPolicy.distanceForSelectedDot(current: camera.distance, readable: target)
        navigate(to: camera)
    }

    /// Pan only far enough to expose the selection, preserving pitch, heading, and zoom.
    func camera(revealing coordinate: Coordinate, in viewport: CGRect, using proxy: MapProxy) -> MapCamera? {
        guard let sample,
              let point = proxy.convert(coordinate.location, to: .local), point.x.isFinite, point.y.isFinite,
              !viewport.contains(point),
              let center = proxy.convert(sample.center.location, to: .local) else { return nil }
        let nearestVisibleX = min(max(point.x, viewport.minX), viewport.maxX)
        let nearestVisibleY = min(max(point.y, viewport.minY), viewport.maxY)
        let offset = CGPoint(x: point.x - nearestVisibleX, y: point.y - nearestVisibleY)
        guard hypot(offset.x, offset.y) > CameraNavigationPolicy.minimumRevealMovementPoints,
              let coordinate = proxy.convert(CGPoint(x: center.x + offset.x, y: center.y + offset.y),
                                             from: .local) else { return nil }
        return MapCamera(centerCoordinate: coordinate, distance: sample.distance,
                         heading: sample.heading, pitch: sample.pitch)
    }
}
