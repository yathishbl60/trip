import TripDomain
import MapEngine
import MapKit
import SwiftUI

extension CameraModel {
    var needsLayout: Bool {
        sample?.differs(from: lastLayoutSample, viewport: size,
                        minimumPanDistance: configuration.layout.minimumPanDistance) == true
    }

    var projectionBounds: MKMapRect? {
        guard sample != nil, pitch < CameraProjectionPolicy.maximumCameraRectPitchDegrees,
              visibleRect.width.isFinite, visibleRect.height.isFinite,
              visibleRect.origin.x.isFinite, visibleRect.origin.y.isFinite,
              !visibleRect.isEmpty, !visibleRect.isNull else { return nil }
        let shortestViewportSide = max(min(size.width, size.height), 1)
        let margin = CameraProjectionPolicy.candidateOverscanPoints / shortestViewportSide
        return visibleRect.insetBy(dx: -visibleRect.width * margin, dy: -visibleRect.height * margin)
    }

    /// Build the first bounds from the live proxy before MapKit emits camera feedback.
    func initialProjectionBounds(using proxy: MapProxy, center: Coordinate) -> MKMapRect? {
        let corners = [CGPoint(x: 0, y: 0), CGPoint(x: size.width, y: 0),
                       CGPoint(x: 0, y: size.height), CGPoint(x: size.width, y: size.height)]
        let points = corners.compactMap { proxy.convert($0, from: .local) }.map(MKMapPoint.init)
        guard points.count == corners.count, points.allSatisfy({ $0.x.isFinite && $0.y.isFinite }) else { return nil }
        let centerX = MKMapPoint(center.location).x
        let wrappedX = points.map { mapX($0.x, nearest: centerX) }
        guard let minX = wrappedX.min(), let maxX = wrappedX.max(),
              let minY = points.map(\.y).min(), let maxY = points.map(\.y).max() else { return nil }
        let maximumWidth = MKMapSize.world.width * CameraProjectionPolicy.maximumWrappedWorldFraction
        guard maxX - minX < maximumWidth else { return MKMapRect.world }
        return MKMapRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    /// Date-line neighbors must be measured in the same copy of MapKit's repeating world.
    private func mapX(_ x: Double, nearest centerX: Double) -> Double {
        let worldWidth = MKMapSize.world.width
        var wrappedX = x
        while wrappedX - centerX > worldWidth / 2 { wrappedX -= worldWidth }
        while centerX - wrappedX > worldWidth / 2 { wrappedX += worldWidth }
        return wrappedX
    }

    func zoomLevel(using proxy: MapProxy) -> ZoomLevel {
        groundScale = nil
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let sampleWidth = CameraProjectionPolicy.scaleSampleWidthPoints
        let leftPoint = CGPoint(x: center.x - sampleWidth / 2, y: center.y)
        let rightPoint = CGPoint(x: center.x + sampleWidth / 2, y: center.y)
        guard let left = proxy.convert(leftPoint, from: .local),
              let right = proxy.convert(rightPoint, from: .local) else { return zoom }
        let metersPerPoint = Coordinate(left).distance(to: Coordinate(right)) / Double(sampleWidth)
        guard metersPerPoint.isFinite, metersPerPoint > 0 else { return zoom }
        groundScale = CameraGroundScale(metersPerPoint: metersPerPoint, camera: sampledCamera, viewport: size)
        return ZoomLevel.resolve(metersPerPoint: metersPerPoint, previous: zoom,
                                 hysteresis: configuration.layout.zoomHysteresis)
    }
}
