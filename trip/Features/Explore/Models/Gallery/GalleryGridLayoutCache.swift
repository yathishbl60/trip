import CoreGraphics

/// Reuses one geometry calculation across SwiftUI's measure and placement passes.
nonisolated struct GalleryGridLayoutCache {
    private var geometry: GalleryGridGeometry?
    private var cachedFrames: [CGRect] = []

    mutating func frames(for geometry: GalleryGridGeometry) -> [CGRect] {
        if self.geometry != geometry {
            self.geometry = geometry
            cachedFrames = geometry.interpolatedFrames
        }
        return cachedFrames
    }
}
