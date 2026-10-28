import TripLocalization
import MapKit
import SwiftUI
import Observation

@MainActor @Observable final class MapAppearanceModel {
    private(set) var style = MapStyleChoice.standard
    private(set) var showsTraffic = false

    var mapStyle: MapStyle {
        switch style {
        case .standard:
            .standard(elevation: .realistic, emphasis: .automatic, pointsOfInterest: .excludingAll, showsTraffic: showsTraffic)
        case .satellite:
            .imagery(elevation: .realistic)
        case .hybrid:
            .hybrid(elevation: .realistic, pointsOfInterest: .excludingAll, showsTraffic: showsTraffic)
        }
    }

    func select(_ style: MapStyleChoice) { self.style = style }
    func setTraffic(_ visible: Bool) { showsTraffic = visible }

    func restore(style: String, showsTraffic: Bool) {
        self.style = MapStyleChoice(rawValue: style) ?? .standard
        self.showsTraffic = showsTraffic
    }
}

nonisolated enum MapStyleChoice: String, CaseIterable, Identifiable {
    case standard, satellite, hybrid
    var id: Self { self }
    var supportsTraffic: Bool { self != .satellite }

    var title: String {
        switch self {
        case .standard: TripText.standard.text
        case .satellite: TripText.satellite.text
        case .hybrid: TripText.hybrid.text
        }
    }

    var symbol: String {
        switch self {
        case .standard: "map"
        case .satellite: "globe"
        case .hybrid: "square.3.layers.3d"
        }
    }
}
