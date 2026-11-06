import CoreGraphics

/// Convert measured global obstructions into clipped, map-local collision rectangles.
nonisolated enum MapViewportOcclusion {
    static func exclusions(mapFrame: CGRect, contentFrame: CGRect, overlays: [CGRect]) -> [CGRect] {
        guard isUsable(mapFrame) else { return [] }
        let measured = isUsable(contentFrame) ? contentFrame.intersection(mapFrame) : .null
        // Parent and map geometry callbacks may arrive separately during a window move.
        let content = isUsable(measured) ? measured : mapFrame
        let frames = edges(outside: content, in: mapFrame) + overlays
        return frames.compactMap { localRectangle($0, in: mapFrame) }
    }

    static func isUsable(_ frame: CGRect) -> Bool {
        !frame.isNull && !frame.isInfinite && !frame.isEmpty && frame.origin.x.isFinite && frame.origin.y.isFinite
            && frame.width.isFinite && frame.height.isFinite && frame.width > 0 && frame.height > 0
            && frame.maxX.isFinite && frame.maxY.isFinite
    }

    private static func edges(outside content: CGRect, in frame: CGRect) -> [CGRect] {
        guard isUsable(content) else { return [frame] }
        return [
            CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: content.minY - frame.minY),
            CGRect(x: frame.minX, y: content.maxY, width: frame.width, height: frame.maxY - content.maxY),
            CGRect(x: frame.minX, y: content.minY, width: content.minX - frame.minX, height: content.height),
            CGRect(x: content.maxX, y: content.minY, width: frame.maxX - content.maxX, height: content.height)
        ]
    }

    private static func localRectangle(_ obstruction: CGRect, in frame: CGRect) -> CGRect? {
        guard isUsable(obstruction) else { return nil }
        let clipped = obstruction.intersection(frame)
        guard isUsable(clipped) else { return nil }
        return clipped.offsetBy(dx: -frame.minX, dy: -frame.minY)
    }
}
