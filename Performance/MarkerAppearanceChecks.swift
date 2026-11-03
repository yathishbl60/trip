import Foundation

@MainActor enum MarkerAppearanceChecks {
    static func run() throws {
        let marker = makeMarker()
        let size = marker.occupiedSize
        try require(marker.opacity == 0, "New marker is already revealed")
        marker.appear()
        try require(marker.opacity == 1 && marker.occupiedSize == size, "Fade-in changed marker size")
        marker.retire()
        try require(marker.opacity == 0 && marker.occupiedSize == size, "Retirement should only fade")
        try continuousMorph()
        try revival()
        try deferredContent()
        try unmountedChanges()
        try nativeViewReentry()
        try MarkerRetirementChecks.run()
        print("PASS: entry state, Reduce Motion, uninterrupted morphs, retirement, and reappearance")
    }

    private static func deferredContent() throws {
        let place = CheckFixtures.place("deferred")
        let marker = MarkerModel(placement: MarkerPlacement(place: place, style: .dot), scale: 1)
        try require(!marker.hasPhotoContent && !marker.hasLabelContent, "Dot eagerly mounts rich content")
        marker.appear()
        marker.update(MarkerPlacement(place: place, style: .thumbnail), scale: 1, reduceMotion: false)
        try require(marker.hasPhotoContent && !marker.hasLabelContent, "Photo unnecessarily mounts labels")
        marker.update(MarkerPlacement(place: place, style: .card), scale: 1, reduceMotion: false)
        marker.update(MarkerPlacement(place: place, style: .dot), scale: 1, reduceMotion: false)
        try require(marker.hasPhotoContent && marker.hasLabelContent, "Demotion destroys morphing content")
    }

    private static func continuousMorph() throws {
        let marker = makeMarker()
        marker.appear()
        for style in MarkerStyle.allCases + MarkerStyle.allCases.reversed() {
            marker.update(MarkerPlacement(place: marker.place, style: style), scale: 1.5, reduceMotion: false)
            marker.appear()
            try require(marker.opacity == 1, "Zoom morph hid an existing marker")
            try require(marker.presentationRevision == 0, "Visible morph rebuilt the artwork hierarchy")
        }
    }

    private static func revival() throws {
        let marker = makeMarker()
        marker.appear()
        let revision = marker.presentationRevision
        marker.retire()
        marker.appear()
        try require(!marker.hasAppeared, "Retired marker was revealed")
        let placement = MarkerPlacement(place: marker.place, style: .dot)
        marker.update(placement, scale: 1, reduceMotion: false)
        try require(marker.presentationRevision == revision + 1, "Reappearance reused stale artwork geometry")
        try require(marker.opacity == 0 && marker.occupiedSize == MarkerStyle.dot.hitSize(scale: 1), "Dot inherited card entry")
        try require(!marker.hasPhotoContent && !marker.hasLabelContent, "Dot revived with stale rich content")
        try require(marker.reservationUntil == nil, "Invisible-to-dot entry reserved a card morph")
        marker.appear(revision: revision)
        try require(marker.opacity == 0, "Stale appearance callback revealed a replacement")
        marker.appear(revision: marker.presentationRevision)
        try require(marker.opacity == 1, "Revived marker stayed invisible")
    }

    private static func unmountedChanges() throws {
        let marker = makeMarker()
        marker.update(MarkerPlacement(place: marker.place, style: .dot), scale: 1.5, reduceMotion: false)
        try require(marker.opacity == 0 && marker.reservationUntil == nil, "Unshown annotation started a morph")
        try require(marker.occupiedSize == MarkerStyle.dot.hitSize(scale: 1.5), "New dot retained card geometry")
        let revision = marker.presentationRevision
        marker.appear(revision: revision - 1)
        try require(marker.opacity == 0, "Stale initial appearance revealed an unmounted view")
    }

    private static func nativeViewReentry() throws {
        let marker = makeMarker()
        marker.appear()
        let revision = marker.presentationRevision
        marker.appear(revision: revision)
        try require(marker.opacity == 1 && marker.presentationRevision == revision, "Native remount restarted entry")
        marker.update(MarkerPlacement(place: marker.place, style: .dot), scale: 1, reduceMotion: false)
        marker.appear(revision: revision)
        try require(marker.opacity == 1 && marker.presentationRevision == revision && marker.style == .dot,
                    "Native reentry hid an active annotation")
    }

    private static func makeMarker() -> MarkerModel {
        MarkerModel(placement: MarkerPlacement(place: CheckFixtures.place("appearance"), style: .card), scale: 1)
    }
}
