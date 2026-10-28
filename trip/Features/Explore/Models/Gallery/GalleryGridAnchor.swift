import CoreGraphics

nonisolated struct GalleryGridAnchor {
    let id: String
    let index: Int
    let fraction: CGFloat
    let viewportY: CGFloat

    init(id: String, index: Int, frame: CGRect, point: CGPoint, offset: CGFloat) {
        self.id = id
        self.index = index
        fraction = min(max((point.y + offset - frame.minY) / max(frame.height, 1), 0), 1)
        viewportY = frame.minY + frame.height * fraction - offset
    }

    func scrollOffset(frame: CGRect, viewport: GalleryGridViewport) -> CGFloat {
        let desired = frame.minY + frame.height * fraction - viewportY
        return min(max(desired, 0), max(0, viewport.contentHeight - viewport.height))
    }
}
