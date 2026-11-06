import TripRouting
import CoreGraphics
import SwiftUI
import TripDomain

extension ExploreModel {
    func resizeMap(_ frame: CGRect) {
        guard camera.frame != frame else { return }
        camera.frame = frame
        camera.size = frame.size
        requestProjection()
    }

    func visibleAreaChanged(_ frame: CGRect) {
        guard camera.contentFrame != frame else { return }
        camera.contentFrame = frame
        selection.viewportChanged()
        requestProjection()
        directionsViewportChanged()
    }

    func detailAreaChanged(_ frame: CGRect, placeID: String, revision: Int) {
        guard !directions.isPresented, selectedPlace?.id == placeID,
              selection.revision == revision, camera.sheetFrame != frame else { return }
        camera.sheetFrame = frame
        selection.viewportChanged()
        if !isSuspended { layout.viewportSettled() }
    }

    func noticeAreaChanged(_ frame: CGRect) {
        guard camera.noticeFrame != frame else { return }
        camera.noticeFrame = frame
        guard !isSuspended else { return }
        layout.viewportSettled()
    }

    func updateAccessibility(scale: CGFloat, reduceMotion: Bool) {
        let limits = MapViewportPolicy.markerScaleRange
        camera.markerScale = min(max(scale, limits.lowerBound), limits.upperBound)
        camera.reduceMotion = reduceMotion
        requestProjection()
    }
}
