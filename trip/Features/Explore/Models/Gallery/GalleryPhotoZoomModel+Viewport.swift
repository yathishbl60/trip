import CoreGraphics

extension GalleryPhotoZoomModel {
    func toggle(at point: CGPoint, size: CGSize, ratio: Double) {
        guard valid(size: size, ratio: ratio) else { return }
        guard scale <= 1 else { reset(); return }
        let fittedWidth = min(size.width, size.height * ratio)
        let fill = max(size.width / max(fittedWidth, 1), size.height / max(fittedWidth / ratio, 1))
        magnify(min(max(fill, 2), 5), anchor: point, size: size, ratio: ratio)
        finishMagnifying(size: size, ratio: ratio)
    }

    func valid(size: CGSize, ratio: Double) -> Bool {
        size.width.isFinite && size.height.isFinite && size.width > 0 && size.height > 0
            && ratio.isFinite && ratio > 0
    }
}
