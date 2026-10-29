import CoreGraphics
import SwiftUI

@MainActor struct PlaceGalleryController {
    let model: PlaceGalleryModel

    var presentation: Binding<Bool> {
        Binding(get: { model.isPresented }, set: model.present)
    }

    var viewerPresented: Binding<Bool> {
        Binding(get: { model.viewer != nil }, set: { if !$0 { model.closeViewer() } })
    }

    var focus: Binding<String?> { Binding(get: { model.focusedID }, set: model.select) }

    var filmstripPosition: Binding<String?> {
        Binding(get: { model.filmstrip.position }, set: model.scrub)
    }

    func scrubPhase(_ phase: ScrollPhase) {
        model.filmstrip.setScrubbing(phase == .interacting || phase == .tracking || phase == .decelerating)
        if phase == .idle { model.filmstrip.follow(model.focusedID) }
    }

    var information: Binding<Bool> {
        Binding(get: { model.showsInformation }, set: model.showInformation)
    }

    var gridInformation: Binding<Bool> {
        Binding(get: { model.viewer == nil && model.showsInformation }, set: model.showInformation)
    }

    var gridPosition: Binding<ScrollPosition> {
        Binding(get: { model.grid.position }, set: { model.grid.position = $0 })
    }

    func open(_ photo: GalleryPhoto) { model.open(photo) }
    func present() { model.present(true) }
    func closeViewer() { model.closeViewer() }
    func move(_ offset: Int) { model.move(offset) }
    func setZoomed(_ zoomed: Bool, photoID: String) {
        model.setZoomed(zoomed, photoID: photoID)
    }
    func observeVisiblePhotos(_ ids: [String]) { model.grid.observeVisiblePhotos(ids) }
    func toggleControls(reduceMotion: Bool) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { model.toggleControls() }
    }
    func showInformation() { model.showInformation(true) }
    func toggleAspectRatio(size: CGSize, reduceMotion: Bool) {
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.25)) {
            model.grid.toggleAspectRatio(size: size, photos: model.photos)
        }
    }
    func select(_ photo: GalleryPhoto, reduceMotion: Bool) {
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.22)) { model.select(photo.id) }
    }

    func zoom(_ direction: CGFloat, size: CGSize, reduceMotion: Bool) {
        var token: Int?
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.28), completionCriteria: .removed) {
            token = model.grid.zoom(direction, size: size, photos: model.photos)
        } completion: {
            if let token { model.grid.completeZoom(token) }
        }
    }

    func finishPinch(reduceMotion: Bool) {
        var token: Int?
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.24), completionCriteria: .removed) {
            token = model.grid.finishPinch()
        } completion: {
            if let token { model.grid.completeZoom(token) }
        }
    }

}
