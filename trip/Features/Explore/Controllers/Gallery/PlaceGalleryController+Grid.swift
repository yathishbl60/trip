import CoreGraphics
import SwiftUI

extension PlaceGalleryController {
    func suspendGrid() { model.grid.suspendInteraction() }

    func magnify(_ value: MagnifyGesture.Value, size: CGSize, reduceMotion: Bool) {
        model.grid.magnify(value, size: size, photos: model.photos, reduceMotion: reduceMotion)
    }

    func observeViewport(_ viewport: GalleryGridViewport) {
        model.grid.observeViewport(viewport)
    }

    func observeFrame(_ frame: CGRect, id: String) {
        model.grid.observeFrame(frame, id: id)
    }

    func resizeGrid(from size: CGSize) {
        model.grid.resize(from: size, photos: model.photos)
    }

    func revealFocusedPhoto() {
        guard model.viewer != nil else { return }
        model.grid.reveal(model.focusedID)
    }
}
