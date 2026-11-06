import CoreGraphics
import SwiftUI

enum TripPaneDivisionChecks {
    private static let minimum = CGSize(width: 180, height: 132)

    static func run() throws {
        try bookAndMirroredBook()
        try tabletop()
        try singlePaneWindow()
        try invalidGeometry()
        try dayMapFallback()
        try narrowInteriorPane()
    }

    private static func bookAndMirroredBook() throws {
        let size = CGSize(width: 720, height: 500)
        for (leading, trailing): (CGFloat, CGFloat) in [(220, 476), (476, 220)] {
            let raw = CGRect(x: leading, y: -90, width: 24, height: 680)
            let clipped = CGRect(x: leading, y: 0, width: 24, height: 500)
            let panes = TripPaneDivision(raw, in: size)
            try require(panes?.sideBySide == true && panes?.frame == clipped, "Book fold lost its local intersection")
            try require(panes?.firstLength == leading && panes?.secondLength == trailing && panes?.gap == 24,
                        "Book pane lengths did not follow the supplied leading-edge coordinates")
        }
    }

    private static func tabletop() throws {
        let size = CGSize(width: 780, height: 600)
        let raw = CGRect(x: -60, y: 240, width: 900, height: 18)
        let clipped = CGRect(x: 0, y: 240, width: 780, height: 18)
        let panes = TripPaneDivision(raw, in: size)
        try require(panes?.sideBySide == false && panes?.frame == clipped, "Tabletop fold acquired a horizontal layout")
        try require(panes?.firstLength == 240 && panes?.secondLength == 342 && panes?.gap == 18,
                    "Tabletop surfaces did not follow the fold")
        let metrics = TripMapLayoutMetrics(size: size, listHeight: 180, division: raw, minimumPaneSize: minimum)
        try require(!metrics.horizontal && metrics.primaryLength == 240 && metrics.detailLength == 342,
                    "Day map used its wide-window fallback for an active tabletop division")
    }

    private static func singlePaneWindow() throws {
        let size = CGSize(width: 320, height: 600)
        let frames = [CGRect(x: -24, y: 0, width: 24, height: 600),
                      CGRect(x: -10, y: 0, width: 24, height: 600),
                      CGRect(x: 306, y: 0, width: 24, height: 600),
                      CGRect(x: 0, y: -6, width: 320, height: 16),
                      CGRect(x: 0, y: 584, width: 320, height: 16),
                      CGRect(x: 400, y: 0, width: 24, height: 600)]
        for frame in frames {
            try require(TripPaneDivision(frame, in: size) == nil, "Edge or outside geometry created a second pane")
        }
    }

    private static func invalidGeometry() throws {
        let size = CGSize(width: 500, height: 700)
        let invalid: [CGRect?] = [nil, .null, .zero, .infinite,
                                  CGRect(x: CGFloat.nan, y: 0, width: 24, height: 700),
                                  CGRect(x: 80, y: 0, width: 24, height: CGFloat.infinity),
                                  CGRect(x: 80, y: 0, width: -24, height: 700),
                                  CGRect(x: 80, y: 0, width: 0, height: 700)]
        for frame in invalid {
            try require(TripPaneDivision(frame, in: size) == nil, "Malformed fold created usable panes")
        }
        let frame = CGRect(x: 80, y: 0, width: 24, height: 700)
        for size in [CGSize.zero, CGSize(width: CGFloat.infinity, height: 700), CGSize(width: 500, height: CGFloat.nan)] {
            try require(TripPaneDivision(frame, in: size) == nil, "Invalid viewport produced a fold")
        }
    }

    private static func dayMapFallback() throws {
        let narrow = CGSize(width: 320, height: 480)
        let edge = CGRect(x: 0, y: 0, width: 24, height: 480)
        let compact = TripMapLayoutMetrics(size: narrow, listHeight: 300, division: edge, minimumPaneSize: minimum)
        try require(!compact.horizontal && compact.spacing == 0 && compact.primaryLength == 240 && compact.detailLength == 240,
                    "A single-pane day map lost its vertical list height limit")
        let wide = TripMapLayoutMetrics(size: CGSize(width: 500, height: 300), listHeight: 240,
                                       division: nil, minimumPaneSize: minimum)
        try require(wide.horizontal && wide.spacing == 0 && wide.primaryLength == 290 && wide.detailLength == 210,
                    "A wide day map lost its ordinary proportions")
    }

    private static func narrowInteriorPane() throws {
        let size = CGSize(width: 500, height: 600)
        for (x, alignment): (CGFloat, Alignment) in [(12, .trailing), (464, .leading)] {
            let fold = CGRect(x: x, y: 0, width: 24, height: 600)
            let map = TripMapLayoutMetrics(size: size, listHeight: 240, division: fold, minimumPaneSize: minimum)
            try require(map.fold == nil && map.spacing == 0 && map.alignment == alignment && !map.horizontal,
                        "An interior sliver kept the folded day picker or put the map on the smaller side")
            try require(map.contentSize == CGSize(width: 464, height: 600) && map.detailLength == 240,
                        "Day map and stops did not use the larger unobstructed surface")
        }
        let fold = CGRect(x: 0, y: 564, width: 500, height: 24)
        let map = TripMapLayoutMetrics(size: size, listHeight: 240, division: fold, minimumPaneSize: minimum)
        try require(map.fold == nil && map.alignment == .top && map.contentSize.height == 564 && map.spacing == 0,
                    "A shallow bottom pane took the stop list away from the usable tabletop surface")
    }
}
