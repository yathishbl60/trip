import CoreGraphics
import SwiftUI

extension GalleryGridModel {
    func magnify(_ value: MagnifyGesture.Value, size: CGSize, photos: [GalleryPhoto], reduceMotion: Bool) {
        guard !awaitsRelease, size.width.isFinite, size.height.isFinite,
              size.width > 0, size.height > 0, !photos.isEmpty else { return }
        if pinch == nil { beginPinch(at: value.startLocation, size: size, photos: photos) }
        pinch?.update(value.magnification)
        guard !reduceMotion, let pinch else { return }
        density = pinch.density
    }

    private func beginPinch(at point: CGPoint, size: CGSize, photos: [GalleryPhoto]) {
        let geometry = geometry(width: size.width, photos: photos)
        if let anchor, let frame = renderedAnchorFrame {
            density = geometry.presentationDensity(frame: frame, index: anchor.index)
        }
        invalidateInteraction()
        let current = self.geometry(width: size.width, photos: photos)
        captureAnchor(at: point, geometry: current, photos: photos)
        pinch = GalleryGridPinch(density: density, scale: current.zoomScale)
    }

    func finishPinch() -> Int? {
        awaitsRelease = false
        guard let pinch else { return nil }
        density = pinch.destination
        self.pinch = nil
        return generation
    }

    func completeZoom(_ token: Int) {
        guard generation == token, pinch == nil else { return }
        reconcileAnchor()
        invalidateInteraction()
    }

    func zoom(_ direction: CGFloat, size: CGSize, photos: [GalleryPhoto]) -> Int? {
        guard !awaitsRelease, pinch == nil, !photos.isEmpty, direction.isFinite, direction != 0,
              size.width.isFinite, size.height.isFinite, size.width > 0, size.height > 0 else { return nil }
        let geometry = geometry(width: size.width, photos: photos)
        if let anchor, let frame = renderedAnchorFrame {
            density = geometry.presentationDensity(frame: frame, index: anchor.index)
        }
        invalidateInteraction()
        captureAnchor(at: .zero, geometry: self.geometry(width: size.width, photos: photos), photos: photos)
        density = direction > 0 ? min(density.rounded(.down) + 1, 2) : max(density.rounded(.up) - 1, 0)
        return generation
    }
}
