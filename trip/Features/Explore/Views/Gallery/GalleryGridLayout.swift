import CoreGraphics
import SwiftUI

nonisolated struct GalleryGridLayout: Layout {
    var density: CGFloat
    let ratios: [Double]
    let usesAspectRatio: Bool

    var animatableData: CGFloat {
        get { density }
        set { density = newValue }
    }

    func makeCache(subviews: Subviews) -> GalleryGridLayoutCache { GalleryGridLayoutCache() }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout GalleryGridLayoutCache) -> CGSize {
        let width = max(1, proposal.width ?? 1)
        let frames = cache.frames(for: geometry(width))
        return CGSize(width: width, height: frames.map(\.maxY).max() ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews,
                       cache: inout GalleryGridLayoutCache) {
        let frames = cache.frames(for: geometry(bounds.width))
        for (index, view) in subviews.enumerated() where frames.indices.contains(index) {
            let frame = frames[index]
            view.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                       anchor: .topLeading, proposal: ProposedViewSize(frame.size))
        }
    }

    private func geometry(_ width: CGFloat) -> GalleryGridGeometry {
        GalleryGridGeometry(width: width, density: density, ratios: ratios,
                            usesAspectRatio: usesAspectRatio)
    }
}

#Preview("Photo grid layout · interpolated") {
    GalleryGridLayout(density: 1.4, ratios: GalleryPhoto.samples.map(\.aspectRatio), usesAspectRatio: false) {
        ForEach(GalleryPhoto.samples) { photo in
            Image(photo.thumbnailName).resizable().scaledToFill().clipped()
        }
    }.frame(width: 390)
}
