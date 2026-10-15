import MapKit

public nonisolated struct SearchArea: Hashable, Sendable {
    public let center: Coordinate
    public let latitudeSpan: Double
    public let longitudeSpan: Double

    public init(_ region: MKCoordinateRegion) {
        let coordinate = Coordinate(region.center)
        center = coordinate.isValid ? coordinate : .bangkok
        latitudeSpan = Self.clamp(region.span.latitudeDelta, maximum: 180)
        longitudeSpan = Self.clamp(region.span.longitudeDelta, maximum: 360)
    }

    public var region: MKCoordinateRegion {
        MKCoordinateRegion(center: center.location,
                           span: MKCoordinateSpan(latitudeDelta: latitudeSpan, longitudeDelta: longitudeSpan))
    }

    public func contains(_ coordinate: Coordinate) -> Bool {
        guard coordinate.isValid else { return false }
        let longitude = abs(coordinate.longitude - center.longitude).truncatingRemainder(dividingBy: 360)
        return abs(coordinate.latitude - center.latitude) <= latitudeSpan / 2
            && min(longitude, 360 - longitude) <= longitudeSpan / 2
    }

    private static func clamp(_ span: Double, maximum: Double) -> Double {
        span.isFinite ? min(max(abs(span), 0.0001), maximum) : 0.06
    }
}

/// Structured keys cannot alias different category combinations or viewport aspect ratios.
public nonisolated struct PlaceSearchRequest: Hashable, Sendable {
    public let area: SearchArea
    public let query: String
    public let categories: Set<PlaceCategory>

    public init(area: SearchArea, query: String, categories: Set<PlaceCategory>) {
        self.area = area
        self.query = query
        self.categories = categories
    }
}
