import CoreGraphics
import SwiftUI

extension GalleryGridModel {
    func captureAnchor(at point: CGPoint, geometry: GalleryGridGeometry, photos: [GalleryPhoto]) {
        let frames = geometry.interpolatedFrames
        let contentPoint = CGPoint(x: point.x, y: point.y + offset)
        guard let index = frames.indices.min(by: {
            distance(contentPoint, to: frames[$0]) < distance(contentPoint, to: frames[$1])
        }), photos.indices.contains(index) else { return }
        anchor = GalleryGridAnchor(id: photos[index].id, index: index, frame: frames[index], point: point, offset: offset)
        renderedAnchorFrame = frames[index]
    }

    func observeFrame(_ frame: CGRect, id: String) {
        guard anchor?.id == id, frame.width > 0, frame.height > 0 else { return }
        renderedAnchorFrame = frame
        reconcileAnchor()
    }

    func observeViewport(_ viewport: GalleryGridViewport) {
        self.viewport = viewport
        reconcileAnchor()
    }

    func reconcileAnchor() {
        guard let anchor, let frame = renderedAnchorFrame, viewport.height > 0 else { return }
        let target = anchor.scrollOffset(frame: frame, viewport: viewport)
        guard abs(target - viewport.offset) > 0.5 else { requestedOffset = nil; return }
        guard requestedOffset.map({ abs($0 - target) > 0.5 }) ?? true else { return }
        requestedOffset = target
        var transaction = Transaction(animation: nil)
        transaction.disablesAnimations = true
        withTransaction(transaction) { position.scrollTo(y: target) }
    }

    private func distance(_ point: CGPoint, to frame: CGRect) -> CGFloat {
        let x = max(frame.minX - point.x, max(0, point.x - frame.maxX))
        let y = max(frame.minY - point.y, max(0, point.y - frame.maxY))
        return x * x + y * y
    }
}
