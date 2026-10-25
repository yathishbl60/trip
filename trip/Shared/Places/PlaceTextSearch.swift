import MapKit
import TripDomain

/// One cancellable MapKit operation. Callers own debounce and result identity.
@MainActor final class PlaceTextSearch {
    private var request: MKLocalSearch?

    func search(_ query: String, near coordinate: Coordinate?) async throws -> [Place] {
        let configuration = MKLocalSearch.Request()
        configuration.naturalLanguageQuery = PlaceSearchQuery(query).text
        configuration.resultTypes = [.pointOfInterest, .address]
        if let coordinate, coordinate.isValid {
            configuration.region = MKCoordinateRegion(center: coordinate.location,
                latitudinalMeters: 30_000, longitudinalMeters: 30_000)
        }
        return try await perform(configuration)
    }

    func search(_ completion: MKLocalSearchCompletion) async throws -> [Place] {
        let configuration = MKLocalSearch.Request(completion: completion)
        configuration.resultTypes = [.pointOfInterest, .address]
        return try await perform(configuration)
    }

    private func perform(_ configuration: MKLocalSearch.Request) async throws -> [Place] {
        let request = MKLocalSearch(request: configuration)
        self.request = request
        defer { self.request = nil }
        let response = try await request.start()
        try Task.checkCancellation()
        return PlaceSearchResults.unique(response.mapItems.map(PlaceFactory.make))
    }

    func cancel() { request?.cancel() }
}
