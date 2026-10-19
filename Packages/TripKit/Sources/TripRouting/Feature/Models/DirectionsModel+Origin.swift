#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import TripDomain

extension DirectionsModel {
    var isEditingOrigin: Bool { presentation.placePicker?.target == .origin }
    var canUseMyLocation: Bool { environment.locationAuthorized() }
    public var waitsForLocation: Bool { startingPoint.usesCurrentLocation && origin == nil }

    func prepareOrigin() -> Bool {
        guard origin == nil else { return true }
        guard startingPoint.usesCurrentLocation else { status = .choosingOrigin; return false }
        status = .waitingForLocation
        startDeadline(configuration.locationTimeout, message: TripText.yourLocationIsUnavailableChooseAStartingPointOr.text)
        environment.requestLocation()
        return false
    }

    func changeOrigin() {
        openPlacePicker(target: .origin, query: startingPoint.place?.name ?? "")
    }

    func chooseOrigin(_ place: Place) {
        guard isDistinctOrigin(place) else { return }
        startingPoint.selection = .place(place)
        closePlacePicker()
        refresh()
    }

    func useMyLocation() {
        guard canUseMyLocation else { return }
        startingPoint.reset(authorized: true, coordinate: environment.currentLocation())
        closePlacePicker()
        refresh()
    }

    func isDistinctOrigin(_ place: Place) -> Bool {
        place.coordinate.isValid && !stops.contains {
            $0.id == place.id || $0.coordinate.distance(to: place.coordinate) < 5
        }
    }

}
#endif
