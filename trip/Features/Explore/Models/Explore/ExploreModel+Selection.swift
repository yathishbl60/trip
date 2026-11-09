import TripRouting
import TripDomain
import MapEngine
import MapKit
import SwiftUI
import CoreGraphics

extension ExploreModel {
    func focus(_ place: Place) {
        browse.close()
        select(nil)
        camera.focus(place.coordinate)
    }

    func exploreIn3D(_ place: Place) {
        browse.close()
        select(nil)
        camera.exploreIn3D(at: place.coordinate)
    }

    func selectAnnotation(_ id: String?, revision: Int) {
        guard let id else {
            if revision == selection.revision { selection.annotationID = nil }
            return
        }
        if directions.isPresented, directions.placeIDs.contains(id) {
            selection.annotationID = id
            return
        }
        guard let marker = layout.markers.first(where: { $0.id == id }), marker.hasAppeared else { return }
        if directions.isPresented {
            if directions.destinationID != marker.id { showDirections(to: marker.place) }
            return
        }
        let choices = annotationChoices(for: marker)
        selectPlace(marker.place)
        selection.nearbyPlaces = choices
    }

    func selectPlace(_ place: Place) {
        history.record(.place(place))
        if browse.isPresented, selectedPlace == nil { browse.context.inspect(from: camera.sampledCamera) }
        let isDot = layout.markers.first(where: { $0.id == place.id })?.style == .dot
        select(place)
        guard isDot else { return }
        camera.zoomToAnnotation(place.coordinate)
    }

    func select(_ place: Place?) {
        if directions.isPresented { dismissDirections() }
        guard selection.select(place) else { return }
        if place != nil {
            browse.invalidate()
            catalog.setSearchPresented(false)
            filters.isPresented = false
            environment.dismissSave()
        }
        camera.sheetFrame = .null
        layout.updateSelection(place?.id)
        requestProjection()
    }

    func revealSelection(using proxy: MapProxy) -> Bool {
        guard !isSuspended, selection.needsFraming, !camera.isMoving, camera.canFrameSelection,
              !directions.isPresented, let place = selectedPlace, !camera.sheetFrame.isNull else { return false }
        let size = layout.markers.first(where: { $0.id == place.id })?.occupiedSize
            ?? MarkerStyle.thumbnail.size
        let exposedFrame = camera.exposedFrame(in: camera.contentFrame)
            .offsetBy(dx: -camera.frame.minX, dy: -camera.frame.minY)
        let viewport = MapViewportPolicy.selectionViewport(in: exposedFrame, markerSize: size)
        guard viewport.width > 0, viewport.height > MapViewportPolicy.minimumSelectionViewportHeight else { return false }
        let next = camera.camera(revealing: place.coordinate, in: viewport, using: proxy)
        selection.framed()
        guard let next else { return false }
        camera.transition(to: next)
        return true
    }
}
