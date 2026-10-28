import CoreGraphics
import MapEngine
import MapKit
import SwiftUI
import TripRouting

extension CameraModel {
    @discardableResult func fitRoute(_ bounds: MKMapRect) -> Bool {
        guard let rect = routeCameraRect(bounds) else { return false }
        if previousCamera == nil { previousCamera = currentCamera }
        isTilted = false
        isRotated = false
        transition(to: .rect(rect), duration: configuration.motion.camera)
        return true
    }

    private func routeCameraRect(_ bounds: MKMapRect) -> MKMapRect? {
        let nativeViewport = contentFrame.isNull ? frame : contentFrame.intersection(frame)
        return RouteMapGeometry.cameraRect(for: bounds, in: nativeViewport,
                                          exposedViewport: exposedFrame(in: nativeViewport), mapSize: size)
    }
}
