import MapKit
import TripDomain

/// A native search capability supplied by a host; UI state stays with its feature.
@MainActor public protocol PlaceSearching: AnyObject {
    func search(_ query: String, near coordinate: Coordinate?) async throws -> [Place]
    func search(_ completion: MKLocalSearchCompletion) async throws -> [Place]
    func cancel()
}
