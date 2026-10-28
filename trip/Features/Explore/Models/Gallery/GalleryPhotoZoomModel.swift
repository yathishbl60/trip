import CoreGraphics
import Observation

@MainActor @Observable final class GalleryPhotoZoomModel {
    private(set) var scale: CGFloat = 1
    private(set) var offset = CGSize.zero
    private var initialScale: CGFloat?
    private var initialOffset = CGSize.zero
    private var panStart: CGSize?
    private var awaitsPinchEnd = false
    private var awaitsPanEnd = false

    func magnify(_ factor: CGFloat, anchor: CGPoint, size: CGSize, ratio: Double) {
        guard !awaitsPinchEnd, factor.isFinite, factor > 0, anchor.x.isFinite, anchor.y.isFinite,
              valid(size: size, ratio: ratio) else { return }
        if initialScale == nil {
            initialScale = scale
            initialOffset = offset
            panStart = nil
        }
        let start = initialScale ?? 1
        scale = min(max(start * factor, 1), 5)
        let change = scale / start - 1
        offset = CGSize(width: initialOffset.width - (anchor.x - size.width / 2 - initialOffset.width) * change,
                        height: initialOffset.height - (anchor.y - size.height / 2 - initialOffset.height) * change)
        clamp(size: size, ratio: ratio)
    }

    func finishMagnifying(size: CGSize, ratio: Double) {
        awaitsPinchEnd = false
        initialScale = nil
        if scale < 1.05 { reset() }
        clamp(size: size, ratio: ratio)
    }

    func pan(_ translation: CGSize, size: CGSize, ratio: Double) {
        guard !awaitsPanEnd, scale > 1, initialScale == nil, translation.width.isFinite,
              translation.height.isFinite, valid(size: size, ratio: ratio) else { return }
        if panStart == nil { panStart = offset }
        offset = CGSize(width: (panStart?.width ?? 0) + translation.width,
                        height: (panStart?.height ?? 0) + translation.height)
        clamp(size: size, ratio: ratio)
    }

    func finishPanning() {
        panStart = nil
        awaitsPanEnd = false
    }

    func settlePan(_ predicted: CGSize, size: CGSize, ratio: Double) {
        guard !awaitsPanEnd else { finishPanning(); return }
        guard let start = panStart else { return }
        guard predicted.width.isFinite, predicted.height.isFinite else { finishPanning(); return }
        offset = CGSize(width: start.width + predicted.width, height: start.height + predicted.height)
        panStart = nil
        clamp(size: size, ratio: ratio)
    }

    func resize(from old: CGSize, to new: CGSize, ratio: Double) {
        guard valid(size: new, ratio: ratio) else { return }
        awaitsPinchEnd = awaitsPinchEnd || initialScale != nil
        awaitsPanEnd = awaitsPanEnd || panStart != nil
        initialScale = nil
        panStart = nil
        if valid(size: old, ratio: ratio) {
            let factor = min(new.width, new.height * ratio) / min(old.width, old.height * ratio)
            offset = CGSize(width: offset.width * factor, height: offset.height * factor)
        }
        clamp(size: new, ratio: ratio)
    }

    func reset() {
        scale = 1
        offset = .zero
        initialScale = nil
        panStart = nil
        awaitsPinchEnd = false
        awaitsPanEnd = false
    }

    func clamp(size: CGSize, ratio: Double) {
        guard valid(size: size, ratio: ratio) else { reset(); return }
        let width = min(size.width, size.height * ratio)
        let height = width / ratio
        let x = max(0, (width * scale - size.width) / 2)
        let y = max(0, (height * scale - size.height) / 2)
        offset.width = min(max(offset.width, -x), x)
        offset.height = min(max(offset.height, -y), y)
    }

}
