#if os(iOS) || os(visionOS)
import Foundation

public nonisolated struct DirectionsConfiguration {
    public var modes: [TravelMode]
    public var maximumStops: Int
    public var requestTimeout: Duration
    public var locationTimeout: Duration
    public var compactHeight: CGFloat
    public var allowsInteractiveDismissal: Bool

    public init(modes: [TravelMode] = [.driving, .walking, .transit, .cycling], maximumStops: Int = 5,
                requestTimeout: Duration = .seconds(45), locationTimeout: Duration = .seconds(20),
                compactHeight: CGFloat = 100, allowsInteractiveDismissal: Bool = false) {
        self.modes = modes
        self.maximumStops = maximumStops
        self.requestTimeout = requestTimeout
        self.locationTimeout = locationTimeout
        self.compactHeight = compactHeight
        self.allowsInteractiveDismissal = allowsInteractiveDismissal
    }
}
#endif
