import CoreGraphics

nonisolated struct GalleryGridPinch {
    let scale: GalleryGridZoomScale
    private(set) var density: CGFloat
    private var lastMagnification: CGFloat = 1

    init(density: CGFloat, scale: GalleryGridZoomScale) {
        self.density = density
        self.scale = scale
    }

    mutating func update(_ magnification: CGFloat) {
        guard magnification.isFinite, magnification > 0 else { return }
        let width = scale.width(at: density) * magnification / lastMagnification
        density = scale.density(for: width)
        lastMagnification = magnification
    }

    var destination: CGFloat { scale.nearestLevel(to: density) }
}
