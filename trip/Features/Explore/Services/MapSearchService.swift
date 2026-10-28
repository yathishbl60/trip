import TripDomain
import MapKit

@MainActor enum MapSearchService {
    static func fetch(area: SearchArea, query: String, categories: Set<PlaceCategory>) async throws -> [Place] {
        let places = try await results(makeSearch(area: area, query: query, categories: categories))
        guard query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              MapDiscoverySearch.needsAreaSearch(places, in: area) else { return places }
        do {
            let discoveries = try await results(MapDiscoverySearch.request(area: area, categories: categories))
            return places + discoveries
        } catch {
            try Task.checkCancellation()
            if places.isEmpty { throw error }
            return places
        }
    }

    private static func results(_ search: MKLocalSearch) async throws -> [Place] {
        try Task.checkCancellation()
        let operation = SearchOperation(search: search)
        return try await withTaskCancellationHandler {
            try await operation.results()
        } onCancel: {
            Task { @MainActor in operation.cancel() }
        }
    }

    private static func makeSearch(area: SearchArea, query: String,
                                   categories: Set<PlaceCategory>) -> MKLocalSearch {
        let all = categories.isEmpty || categories.count == PlaceCategory.allCases.count
        let filter = all ? nil : MKPointOfInterestFilter(including: categories.flatMap(\.mapCategories))
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let request = MKLocalPointsOfInterestRequest(coordinateRegion: area.region)
            request.pointOfInterestFilter = filter
            return MKLocalSearch(request: request)
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = area.region
        request.resultTypes = [.pointOfInterest, .address]
        request.pointOfInterestFilter = filter
        return MKLocalSearch(request: request)
    }
}

@MainActor private final class SearchOperation {
    private let search: MKLocalSearch

    init(search: MKLocalSearch) { self.search = search }

    func results() async throws -> [Place] {
        let response = try await search.start()
        try Task.checkCancellation()
        return response.mapItems.map(PlaceFactory.make)
    }

    func cancel() { search.cancel() }
}
