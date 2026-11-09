import TripLocalization
import TripDomain
import MapKit
import CoreLocation

@MainActor public enum PlaceFactory {
    public static func make(_ item: MKMapItem) -> Place {
        let coordinate = Coordinate(item.location.coordinate)
        let name = item.name ?? TripText.savedPlace.text
        let fallback = "\(name):\(coordinate.latitude):\(coordinate.longitude)"
        let id = item.identifier?.rawValue ?? fallback
        return Place(id: id, name: name, coordinate: coordinate,
                     category: .resolve(item.pointOfInterestCategory), importance: 0.55,
                     rating: nil, reviews: nil, address: item.address?.fullAddress,
                     website: item.url, phoneNumber: item.phoneNumber, isLive: true, mapItemIdentifier: item.identifier?.rawValue)
    }
}
