import CoreGraphics
import SwiftUI

@MainActor struct GalleryPhotoZoomController {
    let model: GalleryPhotoZoomModel

    func toggle(at point: CGPoint, size: CGSize, ratio: Double, reduceMotion: Bool) {
        withAnimation(reduceMotion ? nil : .snappy(duration: 0.25)) {
            model.toggle(at: point, size: size, ratio: ratio)
        }
    }

    func finish(size: CGSize, ratio: Double) { model.finishMagnifying(size: size, ratio: ratio) }
    func reset() { model.reset() }

    func resize(from old: CGSize, to new: CGSize, ratio: Double) {
        model.resize(from: old, to: new, ratio: ratio)
    }

    func magnify(_ value: MagnifyGesture.Value, size: CGSize, ratio: Double) {
        model.magnify(value.magnification, anchor: value.startLocation, size: size, ratio: ratio)
    }

    func pan(_ translation: CGSize, size: CGSize, ratio: Double) {
        model.pan(translation, size: size, ratio: ratio)
    }

    func finishPanning() { model.finishPanning() }

    func resetUnlessFocused(_ focusedID: String?, photoID: String) {
        if focusedID != photoID { model.reset() }
    }

    func enlarge(size: CGSize, ratio: Double, reduceMotion: Bool) {
        guard model.scale == 1 else { return }
        toggle(at: CGPoint(x: size.width / 2, y: size.height / 2),
               size: size, ratio: ratio, reduceMotion: reduceMotion)
    }

    func settlePan(_ predicted: CGSize, size: CGSize, ratio: Double, reduceMotion: Bool) {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) {
            model.settlePan(predicted, size: size, ratio: ratio)
        }
    }
}
