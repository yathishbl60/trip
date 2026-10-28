import CoreGraphics

extension ExploreModel {
    /// Geometry is global; only value rectangles cross into the layout actor.
    var chromeExclusions: [CGRect] {
        let frame = camera.frame
        let content = camera.contentFrame.intersection(frame)
        guard !frame.isEmpty, !content.isNull, !content.isEmpty else { return [] }
        let visible = content.offsetBy(dx: -frame.minX, dy: -frame.minY)
        return [
            CGRect(x: 0, y: 0, width: frame.width, height: visible.minY),
            CGRect(x: 0, y: visible.maxY, width: frame.width, height: frame.height - visible.maxY),
            CGRect(x: 0, y: visible.minY, width: visible.minX, height: visible.height),
            CGRect(x: visible.maxX, y: visible.minY, width: frame.width - visible.maxX, height: visible.height)
        ].filter { !$0.isEmpty } + camera.reservedFrames.map { $0.offsetBy(dx: -frame.minX, dy: -frame.minY) }
    }
}
