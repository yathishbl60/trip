import CoreGraphics
import Foundation

/// Converts finger scale to the actual interpolated cell width, not arbitrary level increments.
nonisolated struct GalleryGridZoomScale {
    let widths: [CGFloat]

    func width(at density: CGFloat) -> CGFloat {
        let value = min(max(density, 0), 2)
        let lower = min(Int(value), 1)
        return widths[lower] + (widths[lower + 1] - widths[lower]) * (value - CGFloat(lower))
    }

    func density(for width: CGFloat) -> CGFloat {
        guard width > widths[0] else { return 0 }
        guard width < widths[2] else { return 2 }
        let lower = width < widths[1] ? 0 : 1
        return CGFloat(lower) + (width - widths[lower]) / max(widths[lower + 1] - widths[lower], 0.001)
    }

    func nearestLevel(to density: CGFloat) -> CGFloat {
        let width = max(width(at: density), 1)
        let index = widths.indices.min { abs(log(widths[$0] / width)) < abs(log(widths[$1] / width)) } ?? 0
        return CGFloat(index)
    }
}
