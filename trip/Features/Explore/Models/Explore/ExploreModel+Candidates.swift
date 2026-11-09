import MapEngine
import MapKit
import TripDomain

extension ExploreModel {
    /// Bound conversions before entering MapProxy; selected places always get a slot.
    func projectionCandidates(in bounds: MKMapRect?, center: Coordinate, coverage: [MapCandidateRegion]) -> [MapCandidate] {
        let visibleIDs = Set(layout.markers.filter(\.isVisible).map(\.id))
        return catalog.visibleIndex.candidates(in: bounds, categories: filters.effectiveCategories, center: center,
                                        selected: selectedPlace, visibleIDs: visibleIDs,
                                        limit: configuration.layout.candidateLimit, coverage: coverage)
    }
}
