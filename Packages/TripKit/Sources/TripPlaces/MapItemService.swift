import MapKit
import TripDomain

@MainActor public protocol MapItemResolving {
    func resolve(_ place: Place) async throws -> MKMapItem
    func cancel()
}

@MainActor public final class MapItemService: MapItemResolving {
    private var request: MKMapItemRequest?
    public init() {}

    public static func identifier(for place: Place) -> MKMapItem.Identifier? {
        guard place.isLive || place.mapItemIdentifier != nil else { return nil }
        return MKMapItem.Identifier(rawValue: place.mapItemIdentifier ?? place.id)
    }

    public func resolve(_ place: Place) async throws -> MKMapItem {
        guard let identifier = Self.identifier(for: place) else { throw CancellationError() }
        let request = MKMapItemRequest(mapItemIdentifier: identifier)
        self.request = request
        defer { if self.request === request { self.request = nil } }
        return try await request.mapItem
    }

    public func cancel() { request?.cancel(); request = nil }
}
