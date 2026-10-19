#if !TRIP_STANDALONE
import TripDomain
#endif
import MapKit
import CoreLocation

/// Cache map points once per catalog change; project only nearby places on camera updates.
public nonisolated struct MapCandidate: Sendable {
    public let place: Place
    public let point: MKMapPoint
    let location: CLLocation

    public init(_ place: Place) {
        self.place = place
        location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let projected = MKMapPoint(place.coordinate.location)
        let world = MKMapSize.world.width
        let x = (projected.x + world).truncatingRemainder(dividingBy: world)
        point = MKMapPoint(x: x, y: projected.y)
    }

    public func isNear(_ rect: MKMapRect) -> Bool {
        guard point.x.isFinite, point.y.isFinite else { return false }
        let world = MKMapSize.world.width
        let offset = abs(point.x - rect.midX).truncatingRemainder(dividingBy: world)
        let horizontal = min(offset, world - offset)
        return horizontal <= rect.width / 2 && (rect.minY...rect.maxY).contains(point.y)
    }
}
