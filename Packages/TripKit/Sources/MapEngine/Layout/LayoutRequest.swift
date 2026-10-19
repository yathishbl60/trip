import CoreGraphics

/// An immutable input snapshot; never contains a live MapProxy.
public nonisolated struct LayoutRequest: Sendable {
    public let candidates: [ProjectedPlace]
    public let viewport: CGRect
    public let exclusions: [CGRect]
    public let zoom: ZoomLevel
    public let scale: CGFloat
    public let selectedID: String?
    public let generation: Int
    public let isSettled: Bool
    public var previous: [String: MarkerStyle]
    public var reservations: [MarkerReservation]
    public var policy: MarkerLayoutPolicy

    public init(candidates: [ProjectedPlace], viewport: CGRect, exclusions: [CGRect],
                zoom: ZoomLevel, scale: CGFloat, selectedID: String?, generation: Int, isSettled: Bool,
                previous: [String: MarkerStyle] = [:],
                reservations: [MarkerReservation] = [], policy: MarkerLayoutPolicy = .init()) {
        self.candidates = candidates
        self.viewport = viewport
        self.exclusions = exclusions
        self.zoom = zoom
        self.scale = scale
        self.selectedID = selectedID
        self.generation = generation
        self.isSettled = isSettled
        self.previous = previous
        self.reservations = reservations
        self.policy = policy
    }

    public var isValid: Bool {
        viewport.isFinite && !viewport.isEmpty && viewport.width <= 16_384 && viewport.height <= 16_384
            && abs(viewport.midX) <= 1_000_000 && abs(viewport.midY) <= 1_000_000
            && scale.isFinite && (1...1.5).contains(scale)
    }
}
