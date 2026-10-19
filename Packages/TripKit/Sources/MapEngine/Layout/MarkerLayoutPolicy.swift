import Foundation
import CoreGraphics

/// Density and responsiveness settings shared by the native map and its layout worker.
public nonisolated struct MarkerLayoutPolicy: Sendable {
    public static let defaultPhotoArea: CGFloat = 32_000
    public static let defaultMinimumPanDistance: CGFloat = 24

    /// Maximum active annotations; fading-out annotations have a separate allowance.
    public let markerLimit: Int
    /// Unique places considered before placement; always at least the active-marker limit.
    public let candidateLimit: Int
    /// Viewport area in square screen points allocated to each icon/image or labeled marker.
    public let photoArea: CGFloat
    /// Minimum time between expensive camera-driven layouts, not animation duration.
    public let interval: Duration
    /// Fraction around a zoom boundary that resists repeated appearance changes.
    public let zoomHysteresis: Double
    /// Accumulated screen-point movement needed before projecting the map again.
    public let minimumPanDistance: CGFloat
    /// Optional selected-place promotion; nil preserves the normal zoom appearance.
    public let selectionStyle: MarkerStyle?
    private let appearances: [ZoomLevel: [MarkerStyle]]

    /// Reserve one fading-out annotation for every five active slots, with at least one slot.
    public var retirementLimit: Int {
        let activeSlotsPerRetiringMarker = 5
        return max(1, markerLimit / activeSlotsPerRetiringMarker)
    }

    /// Invalid floating-point inputs use the defaults below; finite values stay within safe budgets.
    public init(markerLimit: Int = 110, candidateLimit: Int = 600, photoArea: CGFloat = MarkerLayoutPolicy.defaultPhotoArea,
         interval: Duration = .milliseconds(80), zoomHysteresis: Double = ZoomLevel.defaultHysteresis,
         minimumPanDistance: CGFloat = MarkerLayoutPolicy.defaultMinimumPanDistance,
         appearances: [ZoomLevel: [MarkerStyle]] = [:], selectionStyle: MarkerStyle? = nil) {
        self.markerLimit = min(max(markerLimit, Limits.markerCount.lowerBound), Limits.markerCount.upperBound)
        self.candidateLimit = min(max(candidateLimit, self.markerLimit), Limits.maximumCandidates)
        self.photoArea = photoArea.isFinite ? max(photoArea, Limits.minimumPhotoArea) : Self.defaultPhotoArea
        self.interval = min(max(interval, Limits.interval.lowerBound), Limits.interval.upperBound)
        self.zoomHysteresis = zoomHysteresis.isFinite
            ? min(max(zoomHysteresis, Limits.hysteresis.lowerBound), Limits.hysteresis.upperBound) : ZoomLevel.defaultHysteresis
        self.minimumPanDistance = minimumPanDistance.isFinite
            ? min(max(minimumPanDistance, Limits.panDistance.lowerBound), Limits.panDistance.upperBound) : Self.defaultMinimumPanDistance
        self.appearances = appearances
        self.selectionStyle = selectionStyle
    }

    /// Try the most detailed appearance first; every custom ladder keeps a dot fallback.
    public func styles(at zoom: ZoomLevel, selected: Bool = false) -> [MarkerStyle] {
        let styles = appearances[zoom] ?? zoom.styles
        let selection = selected ? selectionFallbacks : []
        return Set(styles + selection + [.dot]).sorted { $0.rawValue > $1.rawValue }
    }

    private var selectionFallbacks: [MarkerStyle] {
        guard let selectionStyle else { return [] }
        return MarkerStyle.allCases.filter { $0.rawValue <= selectionStyle.rawValue }
    }

    private nonisolated enum Limits {
        // Cap mounted annotations and pre-placement work independently.
        static let markerCount = 1...500
        static let maximumCandidates = 25_000
        // Prevent a tiny density setting from turning every place into a photo.
        static let minimumPhotoArea: CGFloat = 2_000
        // Bound work frequency without allowing custom settings to stall updates indefinitely.
        static let interval = Duration.milliseconds(16)...Duration.seconds(1)
        // Keep a real dead band, while still allowing deliberate zoom/pan gestures through.
        static let hysteresis = 0.02...ZoomLevel.maximumHysteresis
        static let panDistance: ClosedRange<CGFloat> = 1...64
    }
}
