#if !TRIP_STANDALONE
import TripLocalization
#endif
import MapKit

public nonisolated enum TravelMode: String, CaseIterable, Identifiable, Sendable {
    case driving, walking, transit, cycling, automatic
    public var id: Self { self }
    public var supportsAvoidance: Bool { self == .driving || self == .automatic }

    var urlMode: String? { self == .automatic ? nil : rawValue }

    public var title: String {
        switch self {
        case .driving: TripText.driving.text
        case .walking: TripText.walking.text
        case .transit: TripText.transit.text
        case .cycling: TripText.cycling.text
        case .automatic: TripText.bestRoute.text
        }
    }

    public var symbol: String {
        switch self {
        case .driving: "car"
        case .walking: "figure.walk"
        case .transit: "tram"
        case .cycling: "bicycle"
        case .automatic: "arrow.triangle.branch"
        }
    }

    var transportType: MKDirectionsTransportType {
        switch self {
        case .driving: .automobile
        case .walking: .walking
        case .transit: .transit
        case .cycling: .cycling
        case .automatic: .any
        }
    }

}
