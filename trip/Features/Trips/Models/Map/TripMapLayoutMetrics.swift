import CoreGraphics
import SwiftUI

/// Keeps the map and stop list visible inside the trip navigation split view.
nonisolated struct TripMapLayoutMetrics {
    let contentSize: CGSize
    let alignment: Alignment
    let listHeight: CGFloat
    private let panes: TripPaneDivision?

    init(size: CGSize, listHeight: CGFloat, division: CGRect?, minimumPaneSize: CGSize) {
        self.listHeight = listHeight
        let measured = TripPaneDivision(division, in: size)
        if let measured, !measured.fitsBoth(minimumWidth: minimumPaneSize.width, minimumHeight: minimumPaneSize.height) {
            panes = nil
            alignment = measured.largerAlignment
            contentSize = CGSize(width: measured.sideBySide ? measured.largerLength : size.width,
                                 height: measured.sideBySide ? size.height : measured.largerLength)
        } else {
            panes = measured
            alignment = .center
            contentSize = size
        }
    }

    var fold: CGRect? { panes?.frame }

    var horizontal: Bool {
        panes?.sideBySide ?? (contentSize.width > contentSize.height)
    }

    var spacing: CGFloat { panes?.gap ?? 0 }

    var primaryLength: CGFloat {
        if let panes { return panes.firstLength }
        return horizontal ? contentSize.width * 0.58 : contentSize.height - min(listHeight, contentSize.height * 0.5)
    }

    var detailLength: CGFloat { max(0, (horizontal ? contentSize.width : contentSize.height) - primaryLength - spacing) }

    static func division(in geometry: GeometryProxy) -> CGRect? {
        TripPaneDivision.activeFrame(in: geometry)
    }
}
