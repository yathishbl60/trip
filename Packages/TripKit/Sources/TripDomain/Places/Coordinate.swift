import MapKit

public nonisolated struct Coordinate: Codable, Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double
    public static let bangkok = Self(latitude: 13.7478, longitude: 100.5514)
    public var isValid: Bool { CLLocationCoordinate2DIsValid(location) }

    public var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public init(_ coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }

    public func distance(to other: Self) -> Double {
        CLLocation(latitude: latitude, longitude: longitude)
            .distance(from: CLLocation(latitude: other.latitude, longitude: other.longitude))
    }
}
