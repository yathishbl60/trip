import CoreGraphics
#if !TRIP_STANDALONE
import TripDomain
#endif

public nonisolated struct ProjectedPlace: Sendable {
    public let place: Place
    public let point: CGPoint

    public init(place: Place, point: CGPoint) {
        self.place = place
        self.point = point
    }
}

public nonisolated struct MarkerPlacement: Sendable {
    public let place: Place
    public let style: MarkerStyle

    public init(place: Place, style: MarkerStyle) {
        self.place = place
        self.style = style
    }
}

public nonisolated struct MarkerReservation: Sendable {
    public let id: String
    public let rect: CGRect

    public init(id: String, rect: CGRect) {
        self.id = id
        self.rect = rect
    }
}
