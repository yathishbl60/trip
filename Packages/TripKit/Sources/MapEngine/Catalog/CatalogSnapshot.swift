import TripDomain
import Foundation

public nonisolated struct CatalogSnapshot: Sendable {
    public let places: [Place]
    public let index: GeographicIndex
    public let counts: [PlaceCategory: Int]

    public init(_ places: [Place]) {
        self.places = places
        index = GeographicIndex(places)
        counts = places.reduce(into: [:]) { $0[$1.category, default: 0] += 1 }
    }
}

public nonisolated struct CatalogSearchUpdate: Sendable {
    public let catalog: CatalogSnapshot
    public let matches: CatalogSnapshot

    public init(catalog: CatalogSnapshot, matches: CatalogSnapshot) {
        self.catalog = catalog
        self.matches = matches
    }
}
