import CoreGraphics
import TripDomain
import SwiftUI

@MainActor struct MapBrowseController {
    let model: ExploreModel

    var path: Binding<[PlaceDetailDestination]> {
        let rootID = model.selection.rootPlace?.id
        let revision = model.browse.revision
        return Binding(get: {
            model.selection.rootPlace.map { [.detail($0)] + model.selection.detailPath } ?? []
        }, set: { path in
            guard model.browse.revision == revision, model.selection.rootPlace?.id == rootID else { return }
            if path.isEmpty { model.returnToResults() }
            else { model.navigatePlaceDetails(to: Array(path.dropFirst())) }
        })
    }

    func panelChanged(_ frame: CGRect, placeID: String?, revision: Int) {
        if let placeID { model.detailAreaChanged(frame, placeID: placeID, revision: revision) }
        else { model.browseAreaChanged(frame, revision: revision) }
    }

    func open() { model.browseMap() }
    func back() { model.returnToResults() }
    func close() { model.dismissMapSheet() }

    func choose(_ place: Place) { model.selectBrowsePlace(place) }

    func areaChanged(_ frame: CGRect, revision: Int) { model.browseAreaChanged(frame, revision: revision) }
}
