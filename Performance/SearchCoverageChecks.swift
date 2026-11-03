import MapKit

enum SearchCoverageChecks {
    static func run() throws {
        let request = makeRequest()
        try require(request.covers(makeRequest(longitude: 100.501)), "Camera jitter repeated the same search")
        try require(!request.covers(makeRequest(longitude: 100.52)), "A meaningful pan did not refresh places")
        try require(!request.covers(makeRequest(span: 0.03)), "Zooming did not refresh places")
        try require(!request.covers(makeRequest(query: "hotel")), "Query change retained obsolete search results")
        try require(!request.covers(makeRequest(categories: [.park])), "Category change did not refresh places")
        try require(makeRequest(longitude: 179.999).covers(makeRequest(longitude: -179.999)),
                    "Camera jitter across the antimeridian repeated a search")
        print("PASS: search coverage ignores camera jitter and refreshes for area, zoom, query, and filter changes")
    }

    private static func makeRequest(longitude: Double = 100.5, span: Double = 0.06,
                                    query: String = "", categories: Set<PlaceCategory> = [.hotel]) -> PlaceSearchRequest {
        let area = SearchArea(MKCoordinateRegion(center: Coordinate(latitude: 13.75, longitude: longitude).location,
                                                 span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)))
        return PlaceSearchRequest(area: area, query: query, categories: categories)
    }
}
