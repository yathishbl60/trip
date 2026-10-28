import TripLocalization
import TripDomain
import MapKit

/// Nearby POI results can fill their limit within a single block at city scale.
@MainActor enum MapDiscoverySearch {
    static func needsAreaSearch(_ places: [Place], in area: SearchArea) -> Bool {
        let region = MKCoordinateRegion(center: area.center.location,
            span: MKCoordinateSpan(latitudeDelta: area.latitudeSpan * 0.3,
                                   longitudeDelta: area.longitudeSpan * 0.3))
        let core = SearchArea(region)
        return places.allSatisfy { core.contains($0.coordinate) }
    }

    static func request(area: SearchArea, categories: Set<PlaceCategory>) -> MKLocalSearch {
        let request = MKLocalSearch.Request()
        let all = categories.isEmpty || categories.count == PlaceCategory.allCases.count
        request.naturalLanguageQuery = all ? TripText.thingsToDo.text : categories.sorted { $0.rawValue < $1.rawValue }
            .map(\.title).joined(separator: ", ")
        request.region = area.region
        request.regionPriority = .required
        request.resultTypes = [.pointOfInterest]
        if !all { request.pointOfInterestFilter = MKPointOfInterestFilter(including: categories.flatMap(\.mapCategories)) }
        return MKLocalSearch(request: request)
    }
}
