import TripRouting
import MapEngine
import TripDomain
import SwiftUI

@MainActor struct PlaceController {
    let model: ExploreModel

    var selection: Binding<Place?> {
        Binding(get: { model.selectedPlace }, set: model.select)
    }

    var mapSheet: Binding<ExploreSheet?> {
        let revision = model.selection.revision
        let browseRevision = model.browse.revision
        let id = model.mapSheet?.id
        return Binding(get: { model.mapSheet }, set: {
            if $0 == nil, model.selection.revision == revision, model.browse.revision == browseRevision, model.mapSheet?.id == id {
                model.dismissMapSheet()
            }
        })
    }

    var mapSelection: Binding<String?> {
        let revision = model.selection.revision
        return Binding(get: { model.selection.annotationID }, set: { model.selectAnnotation($0, revision: revision) })
    }

    var detailPath: Binding<[PlaceDetailDestination]> {
        let rootID = model.selection.rootPlace?.id
        return Binding(get: { model.selection.detailPath }, set: {
            guard model.selection.rootPlace?.id == rootID else { return }
            model.navigatePlaceDetails(to: $0)
        })
    }

    func showNearbyPlaces(_ place: Place) { model.selection.showNearbyPlaces(for: place) }

    func selectNearby(_ place: Place) { model.selectNearbyPlace(place) }

    func appeared(_ marker: MarkerModel, revision: Int) {
        marker.appear(revision: revision)
    }

    func select(_ place: Place) {
        model.selectPlace(place)
    }

    func save(_ place: Place) { model.savePlace(place) }

    func dismiss() { model.dismissMapSheet() }

    func dismiss(_ place: Place) {
        guard model.selectedPlace?.id == place.id, !model.directions.isPresented else { return }
        dismiss()
    }

    func discoverNearby(_ place: Place) {
        guard model.selectedPlace?.id == place.id else { return }
        model.navigatePlaceDetails(to: model.selection.detailPath + [.search(place)])
    }

    func focus(_ place: Place) {
        model.focus(place)
    }

    func exploreIn3D(_ place: Place) { model.exploreIn3D(place) }
}
