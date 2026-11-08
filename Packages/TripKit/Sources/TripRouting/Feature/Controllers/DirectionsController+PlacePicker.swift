#if os(iOS) || os(visionOS)
import SwiftUI
import TripDomain

extension DirectionsController {
    func stopQuery(for session: DirectionsPlacePicker) -> Binding<String> {
        Binding(get: { model.stopSearch.query }, set: { model.searchPlaces($0, session: session) })
    }

    func choosePlace(_ place: Place, session: DirectionsPlacePicker) { model.choosePlace(place, session: session) }
    func useMyLocation(session: DirectionsPlacePicker) { model.useMyLocation(session: session) }
    func loadStops(session: DirectionsPlacePicker) { model.searchPlaces(model.stopSearch.query, session: session) }
    func stopSearching(session: DirectionsPlacePicker) { model.stopSearching(session: session) }
}
#endif
