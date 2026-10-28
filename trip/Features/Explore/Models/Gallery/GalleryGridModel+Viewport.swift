import CoreGraphics
import SwiftUI

extension GalleryGridModel {
    func resize(from old: CGSize, photos: [GalleryPhoto]) {
        let frames = geometry(width: old.width, photos: photos).interpolatedFrames
        let index = frames.firstIndex { $0.maxY > offset }
        awaitsRelease = pinch != nil
        invalidateInteraction()
        density = density.rounded()
        guard let index, photos.indices.contains(index) else { return }
        position.scrollTo(id: photos[index].id, anchor: .top)
    }

    func toggleAspectRatio(size: CGSize, photos: [GalleryPhoto]) {
        guard !isZooming else { return }
        let frames = geometry(width: size.width, photos: photos).interpolatedFrames
        let index = frames.firstIndex { $0.maxY > offset }
        usesAspectRatio.toggle()
        guard let index, photos.indices.contains(index) else { return }
        position.scrollTo(id: photos[index].id, anchor: .top)
    }
}
