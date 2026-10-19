import Foundation

/// Rendering, collision reservations, and cleanup share the same timing contract.
/// Animation durations and settling allowances are measured in seconds.
public nonisolated struct MapMotion: Hashable, Sendable {
    public let morph: Double
    public let fade: Double
    public let camera: Double
    public let selection: Double

    public init(morph: Double = 0.24, fade: Double = 0.16, camera: Double = 0.7,
         selection: Double = 0.16) {
        self.morph = Self.clamp(morph)
        self.fade = Self.clamp(fade)
        self.camera = Self.clamp(camera)
        self.selection = Self.clamp(selection)
    }

    public var reservation: Duration { .seconds(morph + Self.morphSettlingAllowance) }
    public var retirement: Duration { .seconds(fade + Self.fadeSettlingAllowance) }
    public var refinement: Duration { .seconds(max(morph, fade) + Self.refinementSettlingAllowance) }

    // Keep collision space until the size change settles, and artwork until its fade settles.
    private static let morphSettlingAllowance = 0.08
    private static let fadeSettlingAllowance = 0.04
    // Reconsider placement only after both kinds of animation and their reservations settle.
    private static let refinementSettlingAllowance = 0.12
    private static let maximumAnimationDuration = 2.0
    private static let invalidDurationFallback = 0.3

    private static func clamp(_ duration: Double) -> Double {
        duration.isFinite ? min(max(duration, 0), maximumAnimationDuration) : invalidDurationFallback
    }
}
