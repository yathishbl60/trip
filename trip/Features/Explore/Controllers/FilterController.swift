import TripDomain
import MapEngine
import SwiftUI

@MainActor struct FilterController {
    let model: ExploreModel

    var presentation: Binding<Bool> {
        Binding(get: { model.filters.isPresented }, set: { model.filters.isPresented = $0 })
    }

    var zoomSelection: Binding<ZoomLevel> {
        Binding(get: { model.camera.zoom }, set: zoom)
    }

    func show() {
        model.dismissMapSheet()
        if model.catalog.isSearchPresented { model.searchPresentationChanged(false) }
        model.filters.isPresented = true
    }
    func dismiss() { model.filters.isPresented = false }

    func toggle(_ category: PlaceCategory) {
        model.browse.invalidate(clear: true)
        model.filters.toggle(category)
        model.filterPlaces()
        model.scheduleSearch()
    }

    func clear() {
        model.browse.invalidate(clear: true)
        model.filters.selected.removeAll()
        model.filterPlaces()
        model.scheduleSearch()
    }

    func zoom(_ level: ZoomLevel) {
        model.camera.move(to: level)
        dismiss()
    }
}
