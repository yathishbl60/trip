#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import Foundation

extension DirectionsModel {
    var isLoading: Bool { status == .loading || status == .waitingForLocation }
    var availableModes: [TravelMode] {
        var seen: Set<TravelMode> = []
        let modes = configuration.modes.filter { seen.insert($0).inserted }
        return modes.isEmpty ? [.driving] : modes
    }

    var compactDescription: String {
        switch status {
        case .idle, .waitingForLocation: TripText.findingYourLocation.text
        case .choosingOrigin: TripText.chooseAStartingPoint.text
        case .loading: TripText.loadingRoutes.text
        case .unavailable: TripText.directionsUnavailable.text
        case .ready: estimate.map { "\($0.durationText) · \($0.distanceText)" } ?? TripText.openInMaps.text
        }
    }

    var optionsTitle: String {
        if options.timing != .now { return options.timing.title }
        if mode.supportsAvoidance && options.avoidsTolls && options.avoidsHighways { return TripText.avoidTollsAndHighways.text }
        if mode.supportsAvoidance && options.avoidsTolls { return TripText.avoidTolls.text }
        if mode.supportsAvoidance && options.avoidsHighways { return TripText.avoidHighways.text }
        return TripText.options.text
    }
}
#endif
