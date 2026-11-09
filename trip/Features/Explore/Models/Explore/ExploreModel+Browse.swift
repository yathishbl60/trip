import CoreGraphics
import TripDomain

extension ExploreModel {
    func browseMap() {
        dismissMapSheet()
        filters.isPresented = false
        environment.dismissSave()
        selection.presentation.reset()
        browse.open()
        requestProjection()
    }

    func returnToResults() {
        guard browse.isPresented else { return }
        select(nil)
        camera.sheetFrame = .null
        if let restored = browse.context.returnCamera() { camera.transition(to: restored) }
        requestProjection()
    }

    func selectBrowsePlace(_ place: Place) {
        guard browse.items.contains(where: { $0.id == place.id }) else { return }
        selectPlace(place)
    }

    func savePlace(_ place: Place) {
        if browse.isPresented, selectedPlace == nil { selectPlace(place) }
        environment.savePlace?(place)
    }

    func refreshBrowse(_ projection: MapProjection) {
        guard !camera.isMoving, selectedPlace == nil, browse.context.accepts(camera.sampledCamera) else { return }
        guard let region = projection.browseRegion, let center = projection.center else { browse.unavailableArea(); return }
        browse.refresh(index: discoveryIndex, categories: filters.effectiveCategories, region: region,
                       center: center, sample: camera.sample, size: camera.size)
    }

    func browseAreaChanged(_ frame: CGRect, revision: Int) {
        guard browse.isPresented, selectedPlace == nil, selection.revision == revision,
              camera.recordPanelFrame(frame), !isSuspended else { return }
        layout.viewportSettled()
    }
}
