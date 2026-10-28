import CoreGraphics

/// Projection accuracy and work limits, shared by camera feedback and live MapProxy sampling.
nonisolated enum CameraProjectionPolicy {
    // Keep nearby markers ready to enter while panning; both geographic and screen filters use this halo.
    static let candidateOverscanPoints: CGFloat = 240
    // At a steep pitch, use live corner projection (or the full index) instead of native rectangular bounds.
    static let maximumCameraRectPitchDegrees = 60.0
    // Broad corner projections are ambiguous around the date line; fall back to world coverage.
    static let maximumWrappedWorldFraction = 0.75
    // Measure across a short centered segment, not a single pixel susceptible to projection noise.
    static let scaleSampleWidthPoints: CGFloat = 32
    // Rotation/pitch and zoom trigger projection before the normal pan-distance threshold is reached.
    static let orientationChangeDegrees = 0.15
    static let relativeDistanceChange = 0.003

    static func candidateViewport(size: CGSize) -> CGRect {
        CGRect(origin: .zero, size: size)
            .insetBy(dx: -candidateOverscanPoints, dy: -candidateOverscanPoints)
    }
}
