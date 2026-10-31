import MapKit
import SwiftUI
import TripDomain

extension TripMapModel {
    /// Native camera feedback stays unobserved so panning does not rebuild the list.
    func recordCamera(_ camera: MapCamera) { currentCamera = camera }

    func focusCamera(on coordinate: Coordinate, animated: Bool) {
        var camera = currentCamera ?? position.camera
            ?? MapCamera(centerCoordinate: coordinate.location, distance: 1800)
        camera.centerCoordinate = coordinate.location
        currentCamera = camera
        withAnimation(animated ? .smooth(duration: 0.35) : nil) { position = .camera(camera) }
    }
}
