import CoreGraphics
import TripDomain

@MainActor struct MapBrowseController {
    let model: ExploreModel

    func open() { model.browseMap() }
    func back() { model.returnToResults() }
    func close() { model.dismissMapSheet() }

    func choose(_ place: Place) { model.selectBrowsePlace(place) }

    func areaChanged(_ frame: CGRect, revision: Int) { model.browseAreaChanged(frame, revision: revision) }
}
