#if !TRIP_STANDALONE
import TripDomain
#endif
import MapKit
import Foundation
import SwiftUI

nonisolated struct MapCameraSnapshot: Codable, Equatable {
    let center: Coordinate
    let distance: Double
    let heading: Double
    let pitch: Double

    init(_ camera: MapCamera) {
        center = Coordinate(camera.centerCoordinate)
        distance = camera.distance
        heading = camera.heading
        pitch = camera.pitch
    }

    var camera: MapCamera? {
        guard center.isValid, distance.isFinite, heading.isFinite, pitch.isFinite,
              CameraNavigationPolicy.supportedDistances.contains(distance),
              (0...360).contains(heading), (0...90).contains(pitch) else { return nil }
        return MapCamera(centerCoordinate: center.location, distance: distance, heading: heading, pitch: pitch)
    }

    var encoded: String? {
        guard camera != nil, let data = try? JSONEncoder().encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func decode(_ value: String) -> Self? {
        guard value.utf8.count < 1_024, let data = value.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
}
