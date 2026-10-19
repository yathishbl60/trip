#if !TRIP_STANDALONE
import TripDomain
#endif
import CoreLocation

nonisolated struct RankedMapCandidate {
    let candidate: MapCandidate
    let selected: Bool
    let score: Double
    var id: String { candidate.place.id }

    init(candidate: MapCandidate, center: CLLocation, selectedID: String?, visibleIDs: Set<String>) {
        self.candidate = candidate
        selected = candidate.place.id == selectedID
        let continuity = visibleIDs.contains(candidate.place.id) ? 0.35 : 0
        let importance = candidate.place.importance.isFinite ? candidate.place.importance : 0
        score = importance + continuity - candidate.location.distance(from: center) / 80_000
    }

    static func precedes(_ lhs: Self, _ rhs: Self) -> Bool {
        if lhs.selected != rhs.selected { return lhs.selected }
        return lhs.score == rhs.score ? lhs.id < rhs.id : lhs.score > rhs.score
    }
}
