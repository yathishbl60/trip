import Foundation

public nonisolated struct MapDataPolicy: Sendable {
    public let placeLimit: Int
    public let cacheLimit: Int
    public let cacheLifetime: Duration
    public let debounce: Duration
    public let nameMatchRadius: Double?

    public init(placeLimit: Int = 2_000, cacheLimit: Int = 24, cacheLifetime: Duration = .seconds(300),
         debounce: Duration = .milliseconds(500), nameMatchRadius: Double? = 250) {
        self.placeLimit = min(max(placeLimit, 1), 50_000)
        self.cacheLimit = min(max(cacheLimit, 0), 100)
        self.cacheLifetime = max(cacheLifetime, .zero)
        self.debounce = min(max(debounce, .zero), .seconds(5))
        self.nameMatchRadius = nameMatchRadius.flatMap { $0.isFinite && $0 > 0 ? $0 : nil }
    }
}
