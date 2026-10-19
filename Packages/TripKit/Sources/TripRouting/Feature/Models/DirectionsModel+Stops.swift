#if os(iOS) || os(visionOS)
import TripDomain
import Foundation
import SwiftUI

extension DirectionsModel {
    var canAddStop: Bool { stops.count < min(20, max(0, configuration.maximumStops)) }

    var availableStops: [Place] {
        guard presentation.placePicker != nil else { return [] }
        return stopSearch.results.filter(isEditingOrigin ? isDistinctOrigin : isDistinctStop)
    }

    var hasFilteredSearchResults: Bool {
        !stopSearch.isLoading && !stopSearch.results.isEmpty && availableStops.isEmpty
    }

    private func isDistinctStop(_ place: Place) -> Bool {
        let otherPlaces = destinationPlaces.filter { $0.id != presentation.replacingPlaceID }
        return place.coordinate.isValid && !otherPlaces.contains { $0.id == place.id }
            && (origin.map { $0.distance(to: place.coordinate) >= 5 } ?? true)
            && !otherPlaces.contains { $0.coordinate.distance(to: place.coordinate) < 5 }
    }

    func choosePlace(_ place: Place) {
        guard presentation.placePicker != nil else { return }
        if isEditingOrigin { chooseOrigin(place); return }
        guard isDistinctStop(place) else { return }
        if let id = presentation.replacingPlaceID {
            if destination?.id == id { destination = place }
            else if let index = stops.firstIndex(where: { $0.id == id }) { stops[index] = place }
            else { return }
        } else {
            guard canAddStop else { return }
            stops.append(place)
        }
        closePlacePicker()
        refresh()
    }

    func changePlace(_ place: Place) {
        guard destinationPlaces.contains(where: { $0.id == place.id }) else { return }
        openPlacePicker(target: .stop(place.id), query: place.name)
    }

    func removeStops(_ indices: IndexSet, in snapshot: [Place]) {
        guard let edit = IdentifiedListEdit.removing(indices, from: snapshot.map(\.id)),
              edit.apply(to: &stops) else { return }
        refresh()
    }

    func moveStops(_ indices: IndexSet, to offset: Int, in snapshot: [Place]) {
        guard let edit = IdentifiedListEdit.moving(indices, to: offset, in: snapshot.map(\.id)),
              edit.apply(to: &stops) else { return }
        refresh()
    }

    var destinationPlaces: [Place] { stops + [destination].compactMap { $0 } }
}
#endif
