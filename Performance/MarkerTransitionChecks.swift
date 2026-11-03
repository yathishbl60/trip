import Foundation
import CoreGraphics

@MainActor enum MarkerTransitionChecks {
    static func run() async throws {
        try anchoredGeometry()
        try transitionReservations()
        try selectionReservations()
        try fadingReservations()
        try boundedRetirement()
        try await continuity()
        print("PASS: centered anchors, morph reservations, bounded retirees, Reduce Motion cleanup, and dot continuity")
    }

    private static func anchoredGeometry() throws {
        let point = CGPoint(x: 320, y: 600)
        for style in MarkerStyle.allCases {
            let bounds = MarkerGeometry(style: style, scale: 1.5).bounds(at: point)
            try require(bounds.midY == point.y && bounds.midX == point.x, "Morph displaced the marker's map attachment")
            let marker = MarkerModel(placement: MarkerPlacement(place: CheckFixtures.place("a"), style: style), scale: 1.5)
            marker.select(true)
            let selected = MarkerGeometry(style: style, scale: 1.5).bounds(at: point)
            try require(marker.reservation(at: point).rect.contains(selected), "Selection escaped its reserved footprint")
        }
    }

    private static func transitionReservations() throws {
        let point = CGPoint(x: 320, y: 600)
        for start in MarkerStyle.allCases {
            let marker = MarkerModel(placement: MarkerPlacement(place: CheckFixtures.place("morph"), style: start), scale: 1)
            marker.appear()
            for end in MarkerStyle.allCases.reversed() {
                let previous = MarkerGeometry(style: marker.style, scale: marker.scale).bounds(at: point)
                marker.update(MarkerPlacement(place: marker.place, style: end), scale: 1.5, reduceMotion: false)
                let next = MarkerGeometry(style: end, scale: 1.5).bounds(at: point)
                try require(marker.reservation(at: point).rect.contains(previous.union(next)),
                            "Rapid morph reversal released occupied space before its animation completed")
            }
        }
    }

    private static func selectionReservations() throws {
        let marker = MarkerModel(placement: MarkerPlacement(place: CheckFixtures.place("selected"), style: .card), scale: 1)
        marker.appear()
        let unselected = marker.occupiedSize
        marker.select(true)
        let point = CGPoint(x: 500, y: 500)
        let selected = marker.reservation(at: point).rect
        marker.select(false)
        try require(marker.occupiedSize == unselected && marker.reservationUntil == nil,
                    "Selection resized a marker or reserved an unnecessary animation")
        try require(marker.reservation(at: point).rect == selected, "Deselection changed its footprint")
        marker.update(MarkerPlacement(place: marker.place, style: .card), scale: 1, reduceMotion: true)
        try require(marker.reservationUntil == nil, "Reduce Motion retained an animated reservation")
        let motion = MapMotion(morph: 0.1, selection: 1)
        try require(motion.reservation < .seconds(1) && motion.refinement > motion.reservation,
                    "Color-only selection delayed collision refinement")
    }

    private static func fadingReservations() throws {
        let marker = MarkerModel(placement: MarkerPlacement(place: CheckFixtures.place("fading"), style: .card), scale: 1)
        marker.appear()
        marker.select(true)
        marker.update(MarkerPlacement(place: marker.place, style: .dot), scale: 1, reduceMotion: false)
        let point = CGPoint(x: 500, y: 500)
        let before = marker.reservation(at: point).rect
        marker.retire()
        marker.select(false)
        try require(marker.reservation(at: point).rect.contains(before), "Fading morph released occupied space")
        try require(marker.isSelected, "Retiring annotation changed artwork during its fade")
    }

    private static func boundedRetirement() throws {
        let model = LayoutModel(motion: MapMotion(fade: 2))
        defer { model.stop() }
        for frame in 0..<80 {
            let placements = (0..<110).map { MarkerPlacement(place: CheckFixtures.place("\(frame)-\($0)"), style: .thumbnail) }
            model.apply(placements, scale: 1, reduceMotion: false, retirementLimit: 22)
            try require(model.markers.count <= 132, "Fading annotations exceeded the render budget")
            try require(model.markers.filter(\.isVisible).count == 110, "Render budget evicted active markers")
            try require(Set(model.markers.filter(\.isVisible).map(\.id)) == Set(placements.map { $0.place.id }),
                        "Equal-sized membership changes did not publish the new markers")
            model.markers.filter(\.isVisible).forEach { $0.appear() }
        }
        model.apply([], scale: 1, reduceMotion: true)
        try require(model.markers.isEmpty, "Reduce Motion retained invisible annotations")
    }

    private static func continuity() async throws {
        let point = CGPoint(x: 500, y: 500)
        let candidates = ["a-new", "z-existing"].map { ProjectedPlace(place: CheckFixtures.place($0), point: point) }
        var request = CheckFixtures.request(candidates, zoom: .region)
        request.previous = ["z-existing": .dot]
        let result = try await MarkerLayoutEngine().arrange(request)
        try require(result.first?.place.id == "z-existing", "An equal-priority newcomer replaced the visible dot")
    }
}
