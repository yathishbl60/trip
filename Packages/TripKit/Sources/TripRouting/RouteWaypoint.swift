import TripDomain

public nonisolated struct RouteWaypoint: Hashable, Sendable {
    public let id: String
    public let name: String
    public let coordinate: Coordinate

    public init(id: String, name: String, coordinate: Coordinate) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
    }
}
