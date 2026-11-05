import CoreGraphics
import SwiftUI

/// Keeps the map and stop list visible inside the trip navigation split view.
nonisolated struct TripMapLayoutMetrics {
    let size: CGSize
    let listHeight: CGFloat
    let division: CGRect?

    var horizontal: Bool {
        if let fold { return fold.height > fold.width }
        return size.width > size.height
    }

    var spacing: CGFloat { fold.map { horizontal ? $0.width : $0.height } ?? 0 }

    var primaryLength: CGFloat {
        if let fold { return horizontal ? fold.minX : fold.minY }
        return horizontal ? size.width * 0.58 : size.height - min(listHeight, size.height * 0.5)
    }

    var detailLength: CGFloat { max(0, (horizontal ? size.width : size.height) - primaryLength - spacing) }

    private var fold: CGRect? {
        guard let division else { return nil }
        let frame = division.intersection(CGRect(origin: .zero, size: size))
        guard !frame.isNull, !frame.isEmpty else { return nil }
        let separates = frame.height > frame.width
            ? frame.minX > 0 && frame.maxX < size.width
            : frame.minY > 0 && frame.maxY < size.height
        return separates ? frame : nil
    }

    static func division(in geometry: GeometryProxy) -> CGRect? {
        #if os(iOS)
        return geometry.reservedRegions(kind: .division).first(where: \.isActive)?.frame
        #else
        return nil
        #endif
    }
}
