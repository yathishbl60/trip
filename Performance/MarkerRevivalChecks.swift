import Foundation

@MainActor enum MarkerRevivalChecks {
    static func run() throws {
        for style in MarkerStyle.allCases { try interruptedRetirement(to: style) }
        try immediateReentry(reduceMotion: true, fade: 2)
        try immediateReentry(reduceMotion: false, fade: 0)
        try retirementHistory()
    }

    private static func interruptedRetirement(to style: MarkerStyle) throws {
        let marker = makeMarker(fade: 2)
        marker.appear()
        marker.select(true)
        let size = marker.occupiedSize
        let revision = marker.presentationRevision
        marker.retire()
        marker.update(MarkerPlacement(place: marker.place, style: style), scale: 1, reduceMotion: false)
        try require(marker.opacity == 1 && marker.presentationRevision == revision, "Interrupted fade rebuilt visible artwork")
        try require(marker.hasPhotoContent && marker.hasLabelContent, "Interrupted fade discarded mounted content")
        try require(marker.isSelected && !marker.canRemove && marker.hiddenAt == nil, "Revival lost selection or remained retired")
        try require(marker.occupiedSize.width >= size.width && marker.occupiedSize.height >= size.height,
                    "Revival released the fading artwork's occupied envelope")
    }

    private static func immediateReentry(reduceMotion: Bool, fade: Double) throws {
        let marker = makeMarker(fade: fade)
        marker.appear()
        let revision = marker.presentationRevision
        marker.retire()
        marker.update(MarkerPlacement(place: marker.place, style: .dot), scale: 1, reduceMotion: reduceMotion)
        try require(marker.opacity == 0 && marker.presentationRevision == revision + 1, "Immediate hiding reused stale artwork")
        try require(!marker.hasPhotoContent && !marker.hasLabelContent && marker.reservationUntil == nil,
                    "Immediate dot entry inherited rich content or an animated reservation")
        marker.appear(revision: revision)
        try require(marker.opacity == 0, "Stale appearance callback revealed fresh artwork")
        marker.appear(revision: marker.presentationRevision)
        try require(marker.opacity == 1, "Fresh artwork did not appear")
    }

    private static func makeMarker(fade: Double) -> MarkerModel {
        MarkerModel(placement: MarkerPlacement(place: CheckFixtures.place("revival"), style: .card),
                    scale: 1, motion: MapMotion(fade: fade))
    }

    private static func retirementHistory() throws {
        let layout = LayoutModel(motion: MapMotion(fade: 2))
        defer { layout.stop() }
        let placement = MarkerPlacement(place: CheckFixtures.place("continuity"), style: .thumbnail)
        layout.apply([placement], scale: 1, reduceMotion: false)
        let marker = layout.markers[0]
        marker.appear()
        layout.apply([], scale: 1, reduceMotion: false)
        try require(layout.history[marker.id] == .thumbnail, "An interrupted fade lost its gesture appearance ceiling")
        marker.hiddenAt = .now.advanced(by: .seconds(-marker.motion.fade))
        try require(layout.history[marker.id] == nil, "Fully hidden artwork retained a stale gesture appearance")
    }
}
