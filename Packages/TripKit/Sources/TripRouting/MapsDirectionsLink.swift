import Foundation
import TripDomain

public nonisolated struct MapsDirectionsLink {
    private let origin: Coordinate?
    private let destination: Coordinate
    private let stops: [Coordinate]
    private let mode: TravelMode
    private let options: DirectionsOptions

    public init(origin: Coordinate? = nil, destination: Coordinate, stops: [Coordinate] = [],
                mode: TravelMode, options: DirectionsOptions = .init()) {
        self.origin = origin
        self.destination = destination
        self.stops = stops
        self.mode = mode
        self.options = options
    }

    public var url: URL? {
        guard origin?.isValid != false, destination.isValid, stops.allSatisfy(\.isValid) else { return nil }
        var parts = URLComponents(string: "https://maps.apple.com/directions")
        let source = origin.map { [URLQueryItem(name: "source", value: $0.urlValue)] } ?? []
        parts?.queryItems = source + [URLQueryItem(name: "destination", value: destination.urlValue)]
            + stops.map { URLQueryItem(name: "waypoint", value: $0.urlValue) } + mapsPreferences
        return parts?.url
    }
    var mapsPreferences: [URLQueryItem] {
        var result: [URLQueryItem] = []
        if let mode = mode.urlMode { result.append(URLQueryItem(name: "mode", value: mode)) }
        let avoid = avoidedFeatures.joined(separator: ",")
        if !avoid.isEmpty { result.append(URLQueryItem(name: "avoid", value: avoid)) }
        if mode == .transit, !options.transitPreferences.isEmpty {
            let preferences = options.transitPreferences.map(\.rawValue).sorted().joined(separator: ",")
            result.append(URLQueryItem(name: "transit-preferences", value: preferences))
        }
        return result
    }

    private var avoidedFeatures: [String] {
        if mode.supportsAvoidance {
            return [(options.avoidsTolls, "tolls"), (options.avoidsHighways, "highways")].compactMap { $0.0 ? $0.1 : nil }
        }
        guard mode == .walking || mode == .cycling else { return [] }
        return [(options.avoidsBusyRoads, "busy-roads"), (options.avoidsHills, "hills"),
                (options.avoidsStairs, "stairs")].compactMap { $0.0 ? $0.1 : nil }
    }
}

private extension Coordinate {
    nonisolated var urlValue: String { "\(latitude),\(longitude)" }
}
