import CoreGraphics

public nonisolated struct MarkerGeometry: Sendable {
    public let style: MarkerStyle
    public let scale: CGFloat

    public init(style: MarkerStyle, scale: CGFloat) {
        self.style = style
        self.scale = scale
    }

    public func bounds(at point: CGPoint) -> CGRect {
        let size = style.hitSize(scale: scale)
        return CGRect(x: point.x - size.width / 2, y: point.y - size.height / 2,
                      width: size.width, height: size.height)
    }
}

public nonisolated extension CGRect {
    var isFinite: Bool { minX.isFinite && minY.isFinite && maxX.isFinite && maxY.isFinite }
}
