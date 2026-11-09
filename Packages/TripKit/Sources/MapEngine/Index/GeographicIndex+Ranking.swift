#if !TRIP_STANDALONE
import TripDomain
#endif
import MapKit
import CoreLocation

extension GeographicIndex {
    /// Bound expensive projections while preserving visible places and explicit selection.
    public func candidates(in bounds: MKMapRect?, categories: Set<PlaceCategory>, center: Coordinate,
                           selected: Place?, visibleIDs: Set<String>, limit: Int,
                           coverage: [MapCandidateRegion] = []) -> [MapCandidate] {
        guard limit > 0, center.isValid else { return [] }
        var buffer = GeographicCandidateSelection(limit: limit, cellCount: coverage.count)
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        var foundSelection = false
        forEachCandidate(in: bounds, categories: categories) { candidate in
            let cell = coverage.firstIndex { $0.contains(candidate.point) }
            if candidate.place.id == selected?.id { foundSelection = true }
            buffer.insert(RankedMapCandidate(candidate: candidate, center: location,
                selectedID: selected?.id, visibleIDs: visibleIDs, isInViewport: cell != nil), cell: cell)
        }
        if let selected, selected.coordinate.isValid, !foundSelection {
            buffer.insert(RankedMapCandidate(candidate: MapCandidate(selected), center: location,
                                              selectedID: selected.id, visibleIDs: visibleIDs), cell: nil)
        }
        return buffer.candidates
    }
}
