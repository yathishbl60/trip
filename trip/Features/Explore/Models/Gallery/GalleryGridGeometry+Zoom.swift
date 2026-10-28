import CoreGraphics

nonisolated extension GalleryGridGeometry {
    var zoomScale: GalleryGridZoomScale {
        GalleryGridZoomScale(widths: levels.map { columns in
            max(1, (width - CGFloat(columns - 1) * 2) / CGFloat(columns))
        })
    }

    func presentationDensity(frame: CGRect, index: Int) -> CGFloat {
        guard ratios.indices.contains(index) else { return density }
        let candidates = (0..<2).map { segment in
            projection(of: frame, from: frames(at: segment)[index],
                       to: frames(at: segment + 1)[index], level: segment)
        }
        return candidates.min { $0.error < $1.error }?.density ?? density
    }

    private func projection(of frame: CGRect, from first: CGRect, to last: CGRect,
                            level: Int) -> (density: CGFloat, error: CGFloat) {
        let start = [first.minX, first.minY, first.width, first.height]
        let end = [last.minX, last.minY, last.width, last.height]
        let actual = [frame.minX, frame.minY, frame.width, frame.height]
        let delta = zip(end, start).map { $0 - $1 }
        let offset = zip(actual, start).map { $0 - $1 }
        let length = delta.reduce(CGFloat.zero) { $0 + $1 * $1 }
        let dot = zip(offset, delta).reduce(CGFloat.zero) { $0 + $1.0 * $1.1 }
        let fraction = min(max(dot / max(length, 0.001), 0), 1)
        let error = zip(offset, delta).reduce(CGFloat.zero) { result, pair in
            let difference = pair.0 - pair.1 * fraction
            return result + difference * difference
        }
        return (CGFloat(level) + fraction, error)
    }
}
