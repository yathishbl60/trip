#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated enum ZoomLevel: Int, CaseIterable, Sendable {
    case region, district, street

    /// Fractional margins shared by resolution and configurable layout policies.
    public static let defaultHysteresis = 0.12
    public static let maximumHysteresis = 0.35

    // Smaller ground distances per screen point reveal more annotation detail.
    private static let iconThresholdMetersPerPoint = 45.0
    private static let labelThresholdMetersPerPoint = 3.5

    public var title: String {
        switch self {
        case .region: TripText.overview.text
        case .district: TripText.places.text
        case .street: TripText.details.text
        }
    }

    /// Fallback camera distances in meters, used before a live ground-scale measurement exists.
    public var distance: Double {
        switch self {
        case .region: 80_000
        case .district: 8_000
        case .street: 1_400
        }
    }

    /// Overview uses twice the icon threshold, details half the label threshold, and icons their logarithmic midpoint.
    /// Each target remains inside its stage throughout the supported hysteresis range.
    public var preferredMetersPerPoint: Double {
        switch self {
        case .region: Self.iconThresholdMetersPerPoint * 2
        case .district: sqrt(Self.iconThresholdMetersPerPoint * Self.labelThresholdMetersPerPoint)
        case .street: Self.labelThresholdMetersPerPoint / 2
        }
    }

    /// Change stages only after crossing their directional thresholds, preventing boundary flicker.
    public static func resolve(metersPerPoint: Double, previous: Self,
                               hysteresis: Double = ZoomLevel.defaultHysteresis) -> Self {
        guard metersPerPoint.isFinite, metersPerPoint > 0 else { return previous }
        let margin = hysteresis.isFinite ? min(max(hysteresis, 0), maximumHysteresis) : defaultHysteresis
        switch previous {
        case .region:
            return zoomingIn(metersPerPoint: metersPerPoint, margin: margin)
        case .district:
            if metersPerPoint < labelThresholdMetersPerPoint * (1 - margin) { return .street }
            if metersPerPoint > iconThresholdMetersPerPoint * (1 + margin) { return .region }
            return .district
        case .street:
            return zoomingOut(metersPerPoint: metersPerPoint, margin: margin)
        }
    }

    private static func zoomingIn(metersPerPoint: Double, margin: Double) -> Self {
        if metersPerPoint < labelThresholdMetersPerPoint * (1 - margin) { return .street }
        if metersPerPoint < iconThresholdMetersPerPoint * (1 - margin) { return .district }
        return .region
    }

    private static func zoomingOut(metersPerPoint: Double, margin: Double) -> Self {
        if metersPerPoint > iconThresholdMetersPerPoint * (1 + margin) { return .region }
        if metersPerPoint > labelThresholdMetersPerPoint * (1 + margin) { return .district }
        return .street
    }

    public var styles: [MarkerStyle] {
        switch self {
        case .region: [.dot]
        case .district: [.thumbnail, .dot]
        case .street: [.card, .thumbnail, .dot]
        }
    }
}
