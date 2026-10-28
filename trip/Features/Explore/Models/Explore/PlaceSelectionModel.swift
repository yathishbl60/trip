import TripDomain
import Observation

@MainActor @Observable final class PlaceSelectionModel {
    private(set) var place: Place?
    private(set) var rootPlace: Place?
    private(set) var detailPath: [PlaceDetailDestination] = []
    private(set) var revision = 0
    var annotationID: String?
    var nearbyPlaces: [Place] = []
    @ObservationIgnored private(set) var needsFraming = false
    @ObservationIgnored private var followsPlace = false

    @discardableResult func select(_ place: Place?) -> Bool {
        let changed = self.place != place || rootPlace != place || !detailPath.isEmpty
        annotationID = place?.id
        nearbyPlaces = []
        detailPath = []
        rootPlace = place
        guard changed else { return false }
        self.place = place
        revision += 1
        followsPlace = place != nil
        needsFraming = followsPlace
        return true
    }

    var canChooseNearby: Bool { nearbyPlaces.count > 1 && nearbyPlaces.contains { $0.id == place?.id } }

    func showNearbyPlaces(for place: Place) {
        guard self.place?.id == place.id, canChooseNearby else { return }
        navigate(to: detailPath + [.nearby(nearbyPlaces)])
    }

    func navigate(to path: [PlaceDetailDestination]) {
        guard rootPlace != nil, path != detailPath else { return }
        detailPath = path
        place = path.reversed().compactMap(\.detailPlace).first ?? rootPlace
        annotationID = place?.id
        revision += 1
        followsPlace = true
        needsFraming = true
    }

    func viewportChanged() {
        if followsPlace { needsFraming = place != nil }
    }

    func userMoved() {
        followsPlace = false
        needsFraming = false
    }

    func framed() { needsFraming = false }
}
