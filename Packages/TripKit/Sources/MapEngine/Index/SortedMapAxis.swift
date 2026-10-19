import Foundation
import MapKit
#if !TRIP_STANDALONE
import TripDomain
#endif

nonisolated enum MapAxis: Sendable {
    case horizontal, vertical

    func value(_ candidate: MapCandidate) -> Double {
        self == .horizontal ? candidate.point.x : candidate.point.y
    }
}

nonisolated struct SortedMapAxis: Sendable {
    let items: [MapCandidate]
    private let axis: MapAxis

    init(_ candidates: [MapCandidate], axis: MapAxis) {
        self.axis = axis
        items = candidates.sorted {
            let left = axis.value($0), right = axis.value($1)
            return left == right ? $0.place.id < $1.place.id : left < right
        }
    }

    func slice(_ range: ClosedRange<Double>) -> ArraySlice<MapCandidate> {
        items[bound(range.lowerBound, after: false)..<bound(range.upperBound, after: true)]
    }

    private func bound(_ value: Double, after: Bool) -> Int {
        var lower = 0
        var upper = items.count
        while lower < upper {
            let middle = lower + (upper - lower) / 2
            let candidate = axis.value(items[middle])
            if candidate < value || (after && candidate == value) { lower = middle + 1 }
            else { upper = middle }
        }
        return lower
    }
}
