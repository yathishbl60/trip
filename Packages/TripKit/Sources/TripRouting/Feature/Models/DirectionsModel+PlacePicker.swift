#if os(iOS) || os(visionOS)
import TripDomain
import Foundation

extension DirectionsModel {
    func beginAddingStop() {
        guard canAddStop else { return }
        openPlacePicker(target: .stop(nil), query: "")
    }

    func openPlacePicker(target: DirectionsPlaceTarget, query: String) {
        stopSearch.reset()
        stopSearch.query = query
        presentation.placePicker = DirectionsPlacePicker(target: target)
        if presentation.auxiliary?.screen != .stops { presentation.auxiliary = DirectionsAuxiliary(.placePicker) }
    }

    func closePlacePicker() {
        presentation.placePicker = nil
        if presentation.auxiliary?.screen == .placePicker { presentation.auxiliary = nil }
        stopSearch.reset()
    }

    func showAuxiliary(_ screen: DirectionsAuxiliaryScreen) {
        closePlacePicker()
        presentation.auxiliary = DirectionsAuxiliary(screen)
    }

    func dismissAuxiliary() {
        closePlacePicker()
        presentation.auxiliary = nil
    }

    func searchPlaces(_ query: String, session: DirectionsPlacePicker) {
        guard presentation.placePicker?.id == session.id else { return }
        stopSearch.search(query, environment: environment)
    }

    func stopSearching(session: DirectionsPlacePicker) {
        guard presentation.placePicker?.id == session.id else { return }
        stopSearch.stop()
    }

    func choosePlace(_ place: Place, session: DirectionsPlacePicker) {
        guard presentation.placePicker?.id == session.id,
              let current = availableStops.first(where: { $0.id == place.id }) else { return }
        choosePlace(current)
    }

    func useMyLocation(session: DirectionsPlacePicker) {
        guard presentation.placePicker?.id == session.id, isEditingOrigin else { return }
        useMyLocation()
    }
}
#endif
