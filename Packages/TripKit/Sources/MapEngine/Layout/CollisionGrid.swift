import Foundation
import CoreGraphics

/// A screen-space spatial hash: only neighboring occupied cells are examined.
nonisolated struct CollisionGrid {
    private var cells: [Cell: [Occupant]] = [:]
    private let cellSize: CGFloat = 64

    func intersects(_ rect: CGRect, ignoring id: String) -> Bool {
        for x in columns(rect) {
            for y in rows(rect) {
                guard let occupants = cells[Cell(x: x, y: y)] else { continue }
                if occupants.contains(where: { $0.id != id && $0.rect.intersects(rect) }) { return true }
            }
        }
        return false
    }

    mutating func insert(_ rect: CGRect, id: String? = nil) {
        for x in columns(rect) {
            for y in rows(rect) {
                cells[Cell(x: x, y: y), default: []].append(Occupant(id: id, rect: rect))
            }
        }
    }

    private func columns(_ rect: CGRect) -> ClosedRange<Int> {
        Int(floor(rect.minX / cellSize))...Int(floor(rect.maxX / cellSize))
    }

    private func rows(_ rect: CGRect) -> ClosedRange<Int> {
        Int(floor(rect.minY / cellSize))...Int(floor(rect.maxY / cellSize))
    }
}

nonisolated private struct Occupant {
    let id: String?
    let rect: CGRect
}

nonisolated private struct Cell: Hashable {
    let x: Int
    let y: Int
}
