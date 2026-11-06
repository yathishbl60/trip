import CoreGraphics

/// Screen-point spacing that keeps places clear of location artwork and presentation chrome.
nonisolated enum MapViewportPolicy {
    private static let locationClearanceRadius: CGFloat = 24
    private static let sheetHorizontalClearance: CGFloat = 8
    private static let sheetVerticalClearance: CGFloat = 20
    private static let selectionEdgeClearance: CGFloat = 32
    private static let selectionArtworkClearance: CGFloat = 12
    // Avoid camera corrections when a sheet leaves too little map to reveal a place usefully.
    static let minimumSelectionViewportHeight: CGFloat = 80
    // Bound annotation density at accessibility sizes; full place text remains in the detail sheet.
    static let markerScaleRange: ClosedRange<CGFloat> = 1...1.5

    static func locationExclusion(at point: CGPoint) -> CGRect {
        CGRect(origin: point, size: .zero)
            .insetBy(dx: -locationClearanceRadius, dy: -locationClearanceRadius)
    }

    static func sheetExclusion(_ frame: CGRect) -> CGRect {
        guard MapViewportOcclusion.isUsable(frame) else { return .null }
        return frame.insetBy(dx: -sheetHorizontalClearance, dy: -sheetVerticalClearance)
    }

    static func selectionViewport(in frame: CGRect, markerSize: CGSize) -> CGRect {
        let horizontalClearance = max(selectionEdgeClearance, markerSize.width / 2 + selectionArtworkClearance)
        let verticalClearance = max(selectionEdgeClearance, markerSize.height / 2 + selectionArtworkClearance)
        return frame.insetBy(dx: horizontalClearance, dy: verticalClearance)
    }
}
