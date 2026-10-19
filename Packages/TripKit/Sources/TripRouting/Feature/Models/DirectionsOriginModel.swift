#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import Observation
import TripDomain

@MainActor @Observable final class DirectionsOriginModel {
    var selection = DirectionsOriginSelection.unspecified
    var location: Coordinate?

    var coordinate: Coordinate? {
        switch selection {
        case .unspecified: nil
        case .currentLocation: location
        case .place(let place): place.coordinate
        }
    }

    var place: Place? {
        if case .place(let place) = selection { return place }
        return nil
    }

    var usesCurrentLocation: Bool { selection == .currentLocation }
    var title: String { usesCurrentLocation ? TripText.myLocation.text : place?.name ?? TripText.chooseStartingPoint.text }
    var symbol: String { usesCurrentLocation ? "location.fill" : place?.category.symbol ?? "magnifyingglass" }

    func reset(authorized: Bool = false, coordinate: Coordinate? = nil) {
        selection = authorized ? .currentLocation : .unspecified
        location = coordinate?.isValid == true ? coordinate : nil
    }
}

nonisolated enum DirectionsOriginSelection: Equatable {
    case unspecified, currentLocation, place(Place)
}
#endif
