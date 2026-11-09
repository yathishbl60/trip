import Foundation
import TripDomain
import TripRouting

nonisolated struct MapTravelKey: Hashable {
    let origin: Coordinate
    let destination: Coordinate
    let mode: TravelMode
}

nonisolated struct MapTravelCache {
    private var entries: [MapTravelKey: CachedTravelTime] = [:]

    func estimate(for key: MapTravelKey, now: Date = .now) -> DirectionsEstimate? {
        guard let entry = entries[key], now.timeIntervalSince(entry.date) < 120 else { return nil }
        return entry.estimate
    }

    mutating func store(_ estimate: DirectionsEstimate, for key: MapTravelKey, now: Date = .now) {
        entries[key] = CachedTravelTime(estimate: estimate, date: now)
        if entries.count > 24, let oldest = entries.min(by: { $0.value.date < $1.value.date })?.key {
            entries[oldest] = nil
        }
    }

    private struct CachedTravelTime {
        let estimate: DirectionsEstimate
        let date: Date
    }
}
