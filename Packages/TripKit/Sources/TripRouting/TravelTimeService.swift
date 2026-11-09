import CoreLocation
import MapKit
import TripDomain

@MainActor public protocol TravelTimeEstimating: Sendable {
    func estimate(from origin: Coordinate, to destination: Coordinate, mode: TravelMode) async throws -> DirectionsEstimate
}

@MainActor public struct TravelTimeService: TravelTimeEstimating {
    private let provider: any DirectionsProviding

    public init(provider: any DirectionsProviding = MapDirectionsService()) { self.provider = provider }

    public func estimate(from origin: Coordinate, to destination: Coordinate, mode: TravelMode) async throws -> DirectionsEstimate {
        guard origin.isValid, destination.isValid else { throw DirectionsFailure.unavailable }
        let request = MKDirections.Request()
        request.source = Self.item(origin)
        request.destination = Self.item(destination)
        request.transportType = mode == .walking ? .walking : .automobile
        request.departureDate = .now
        guard case .estimate(let eta) = try await provider.calculate(request, etaOnly: true) else {
            throw DirectionsFailure.unavailable
        }
        let estimate = DirectionsEstimate(travelTime: eta.expectedTravelTime, distance: eta.distance,
                                         arrival: eta.expectedArrivalDate)
        guard estimate.isValid else { throw DirectionsFailure.unavailable }
        return estimate
    }

    private static func item(_ coordinate: Coordinate) -> MKMapItem {
        MKMapItem(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), address: nil)
    }
}
