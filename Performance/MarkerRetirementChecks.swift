import Foundation

@MainActor enum MarkerRetirementChecks {
    static func run() throws {
        try unshownRetirement()
        try replacementBeforeAppearance()
        try visibleRetirement()
    }

    private static func unshownRetirement() throws {
        let placement = MarkerPlacement(place: CheckFixtures.place("unshown"), style: .card)
        let marker = MarkerModel(placement: placement, scale: 1)
        try require(!marker.canRemove, "Pending native appearance was considered retired")
        marker.retire()
        try require(marker.canRemove && marker.reservationUntil == nil,
                    "Unshown annotation reserved a phantom fade")
        marker.update(placement, scale: 1, reduceMotion: false)
        try require(!marker.canRemove && marker.isVisible, "Reentry inherited immediate retirement")
        marker.retire()
        try require(marker.canRemove, "Unshown reentry started a retirement animation")
    }

    private static func replacementBeforeAppearance() throws {
        let model = LayoutModel()
        defer { model.stop() }
        let first = MarkerPlacement(place: CheckFixtures.place("first"), style: .card)
        let next = MarkerPlacement(place: CheckFixtures.place("next"), style: .dot)
        model.apply([first], scale: 1, reduceMotion: false)
        model.apply([next], scale: 1, reduceMotion: false)
        try require(model.markers.map(\.id) == [next.place.id], "Superseded unshown artwork remained mounted")
        try require(model.cleanupTask == nil && !model.needsRefinement,
                    "Unshown retirement scheduled unnecessary cleanup or collision refinement")
    }

    private static func visibleRetirement() throws {
        let model = LayoutModel(motion: MapMotion(fade: 2))
        defer { model.stop() }
        let placement = MarkerPlacement(place: CheckFixtures.place("visible"), style: .card)
        model.apply([placement], scale: 1, reduceMotion: false)
        let marker = model.markers[0]
        marker.appear()
        model.apply([], scale: 1, reduceMotion: false)
        try require(model.markers.count == 1 && !marker.canRemove && marker.reservationUntil != nil,
                    "Visible artwork lost its fade or collision reservation")
        model.stop()
        try require(model.markers.isEmpty && model.cleanupTask == nil, "Suspension retained retiring artwork")
    }
}
