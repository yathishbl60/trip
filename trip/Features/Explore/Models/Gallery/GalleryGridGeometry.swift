import CoreGraphics
import Foundation

/// Interpolates stable photo frames rather than replacing grids during a pinch.
nonisolated struct GalleryGridGeometry: Equatable {
    let width: CGFloat
    let density: CGFloat
    let ratios: [Double]
    let usesAspectRatio: Bool

    var levels: [Int] {
        [max(5, Int(width / 80)), max(3, Int(width / 140)), max(1, Int(width / 440))]
    }

    func frames(at level: Int) -> [CGRect] {
        let level = min(max(level, 0), 2)
        let columns = levels[level]
        let side = max(1, (width - CGFloat(columns - 1) * 2) / CGFloat(columns))
        var y: CGFloat = 0
        var result: [CGRect] = []
        for row in stride(from: 0, to: ratios.count, by: columns) {
            let range = row..<min(row + columns, ratios.count)
            let rowFrames = frames(in: range, side: side, columns: columns, y: y, original: usesAspectRatio || level == 2)
            result += rowFrames
            y += (rowFrames.first?.height ?? side) + 2
        }
        return result
    }

    private func frames(in range: Range<Int>, side: CGFloat, columns: Int, y: CGFloat, original: Bool) -> [CGRect] {
        let totalRatio = range.reduce(CGFloat(columns - range.count)) { $0 + ratios[$1] }
        let height = original ? (width - CGFloat(columns - 1) * 2) / max(totalRatio, 0.4) : side
        var x: CGFloat = 0
        return range.map { index in
            let itemWidth = original ? height * ratios[index] : side
            let frame = CGRect(x: x, y: y, width: itemWidth, height: height)
            x += itemWidth + 2
            return frame
        }
    }

    var interpolatedFrames: [CGRect] {
        let clamped = min(max(density, 0), 2)
        let lower = Int(clamped.rounded(.down))
        let fraction = clamped - CGFloat(lower)
        let first = frames(at: lower)
        let second = frames(at: min(lower + 1, 2))
        return zip(first, second).map { a, b in
            CGRect(x: a.minX + (b.minX - a.minX) * fraction,
                   y: a.minY + (b.minY - a.minY) * fraction,
                   width: a.width + (b.width - a.width) * fraction,
                   height: a.height + (b.height - a.height) * fraction)
        }
    }

}
