#if DEBUG
import TripDomain
import Foundation

actor LocalPlaceProvider: PlaceProviding {
    private let places: [Place]

    init(places: [Place]) { self.places = places }
    func initialPlaces() -> [Place] { places }

    func search(_ request: PlaceSearchRequest) throws -> [Place] {
        try Task.checkCancellation()
        let query = PlaceSearchQuery(request.query)
        return places.filter {
            request.area.contains($0.coordinate) && (request.categories.isEmpty || request.categories.contains($0.category))
                && query.matches($0.searchFields)
        }
    }
}
#endif
