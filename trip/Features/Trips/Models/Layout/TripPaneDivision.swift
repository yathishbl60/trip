import CoreGraphics
import SwiftUI

/// Lengths follow SwiftUI's leading edge, matching the default mirrored reserved-region coordinates.
nonisolated struct TripPaneDivision {
    let frame: CGRect
    let sideBySide: Bool
    let firstLength: CGFloat
    let secondLength: CGFloat
    var gap: CGFloat { sideBySide ? frame.width : frame.height }
    var largerLength: CGFloat { max(firstLength, secondLength) }

    var largerAlignment: Alignment {
        let first = firstLength >= secondLength
        if sideBySide { return first ? .leading : .trailing }
        return first ? .top : .bottom
    }

    func fitsBoth(minimumWidth: CGFloat, minimumHeight: CGFloat) -> Bool {
        min(firstLength, secondLength) >= (sideBySide ? minimumWidth : minimumHeight)
    }

    init?(_ division: CGRect?, in size: CGSize) {
        guard let division, !division.isInfinite, division.origin.x.isFinite, division.origin.y.isFinite,
              division.size.width.isFinite, division.size.width > 0,
              division.size.height.isFinite, division.size.height > 0,
              size.width.isFinite, size.height.isFinite, size.width > 0, size.height > 0 else { return nil }
        let frame = division.intersection(CGRect(origin: .zero, size: size))
        guard !frame.isNull, !frame.isEmpty else { return nil }
        let sideBySide = division.height > division.width
        let first = sideBySide ? frame.minX : frame.minY
        let second = sideBySide ? size.width - frame.maxX : size.height - frame.maxY
        guard first > 0, second > 0 else { return nil }
        self.frame = frame
        self.sideBySide = sideBySide
        firstLength = first
        secondLength = second
    }

    static func activeFrame(in geometry: GeometryProxy) -> CGRect? {
        #if os(iOS)
        return geometry.reservedRegions(kind: .division).first {
            $0.isActive && TripPaneDivision($0.frame, in: geometry.size) != nil
        }?.frame
        #else
        return nil
        #endif
    }
}
