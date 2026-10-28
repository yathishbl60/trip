import CoreGraphics
import Observation
import SwiftUI

@MainActor @Observable final class GalleryGridModel {
    var density: CGFloat = 1
    var usesAspectRatio = false
    var position = ScrollPosition(idType: String.self)
    var anchor: GalleryGridAnchor?
    @ObservationIgnored var viewport = GalleryGridViewport()
    @ObservationIgnored var pinch: GalleryGridPinch?
    @ObservationIgnored var renderedAnchorFrame: CGRect?
    @ObservationIgnored var requestedOffset: CGFloat?
    @ObservationIgnored var generation = 0
    @ObservationIgnored var awaitsRelease = false
    @ObservationIgnored private var visibleIDs: Set<String> = []

    var offset: CGFloat { max(0, viewport.offset) }
    var isZooming: Bool { anchor != nil }

    func geometry(width: CGFloat, photos: [GalleryPhoto]) -> GalleryGridGeometry {
        GalleryGridGeometry(width: width, density: density, ratios: photos.map(\.aspectRatio),
                            usesAspectRatio: usesAspectRatio)
    }

    func reveal(_ id: String?) {
        guard !isZooming, let id, !visibleIDs.contains(id) else { return }
        position.scrollTo(id: id, anchor: .center)
        visibleIDs = [id]
    }

    func observeVisiblePhotos(_ ids: [String]) {
        guard !ids.isEmpty, !isZooming else { return }
        visibleIDs = Set(ids)
    }

    func invalidateInteraction() {
        generation += 1
        pinch = nil
        anchor = nil
        renderedAnchorFrame = nil
        requestedOffset = nil
        visibleIDs = []
    }

    func suspendInteraction() {
        guard isZooming || awaitsRelease else { return }
        density = density.rounded()
        awaitsRelease = false
        invalidateInteraction()
    }
}
