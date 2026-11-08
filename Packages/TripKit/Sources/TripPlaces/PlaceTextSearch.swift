import MapKit
import TripDomain

/// Latest-request search with native cancellation. Callers own debounce and UI identity.
@MainActor public final class PlaceTextSearch: PlaceSearching {
    private var operation: PlaceSearchOperation?

    public init() {}

    public func search(_ query: String, near coordinate: Coordinate?) async throws -> [Place] {
        let configuration = MKLocalSearch.Request()
        configuration.naturalLanguageQuery = PlaceSearchQuery(query).text
        configuration.resultTypes = [.pointOfInterest, .address]
        if let coordinate, coordinate.isValid {
            configuration.region = MKCoordinateRegion(center: coordinate.location,
                latitudinalMeters: 30_000, longitudinalMeters: 30_000)
        }
        return try await perform(configuration)
    }

    public func search(_ completion: MKLocalSearchCompletion) async throws -> [Place] {
        let configuration = MKLocalSearch.Request(completion: completion)
        configuration.resultTypes = [.pointOfInterest, .address]
        return try await perform(configuration)
    }

    private func perform(_ configuration: MKLocalSearch.Request) async throws -> [Place] {
        try Task.checkCancellation()
        cancel()
        let operation = PlaceSearchOperation(configuration)
        self.operation = operation
        defer { if self.operation === operation { self.operation = nil } }
        return try await operation.places()
    }

    public func cancel() {
        operation?.cancel()
        operation = nil
    }
}
