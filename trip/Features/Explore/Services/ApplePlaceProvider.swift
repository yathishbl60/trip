import TripDomain
import Foundation

actor ApplePlaceProvider: PlaceProviding {
    func initialPlaces() -> [Place] { [] }

    func search(_ request: PlaceSearchRequest) async throws -> [Place] {
        try await MapSearchService.fetch(area: request.area, query: request.query, categories: request.categories)
    }
}
