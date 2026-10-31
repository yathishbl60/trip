import Foundation
import MapKit
import CoreLocation
import TripDomain
import TripRouting

struct TripPlanningSegment: Identifiable {
    let start: TripStop
    let end: TripStop
    let route: MKRoute?
    var id: String { "\(start.id)-\(end.id)" }
    var isLocated: Bool { start.place.coordinate.isValid && end.place.coordinate.isValid }
    var isStationary: Bool { isLocated && start.place.coordinate == end.place.coordinate }
    var minutes: Int? {
        if isStationary { return 0 }
        guard let route, route.expectedTravelTime.isFinite, route.expectedTravelTime >= 0,
              route.expectedTravelTime < Double(Int.max / 60) else { return nil }
        return Int(ceil(route.expectedTravelTime / 60))
    }
    var coordinates: [CLLocationCoordinate2D] { [start.place.coordinate.location, end.place.coordinate.location] }
}

struct TripPlanningRouteKey: Hashable {
    let start: Coordinate
    let end: Coordinate
    let mode: TravelMode
}
