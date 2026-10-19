import TripDomain
import MapKit
import CoreLocation
import Foundation

public struct DirectionsPlan {
    let requests: [MKDirections.Request]
    let mode: TravelMode
    let options: DirectionsOptions

    public init(origin: Coordinate?, places: [RouteWaypoint], mode: TravelMode, options: DirectionsOptions) throws {
        guard let origin, origin.isValid, !places.isEmpty, places.allSatisfy({ $0.coordinate.isValid }) else {
            throw DirectionsFailure.unavailable
        }
        self.mode = mode
        self.options = options
        guard options.timing == .now || options.date.timeIntervalSinceNow >= -60 else { throw DirectionsFailure.pastDate }
        let points = [origin] + places.map(\.coordinate)
        requests = zip(points, places).map { start, place in
            let request = MKDirections.Request()
            request.source = Self.item(start, name: nil)
            request.destination = Self.item(place.coordinate, name: place.name)
            request.transportType = mode.transportType
            request.requestsAlternateRoutes = true
            options.apply(to: request, mode: mode)
            return request
        }
    }

    private static func item(_ coordinate: Coordinate, name: String?) -> MKMapItem {
        let item = MKMapItem(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), address: nil)
        item.name = name
        return item
    }
}

public nonisolated enum DirectionsFailure: Error { case unavailable, pastDate }
