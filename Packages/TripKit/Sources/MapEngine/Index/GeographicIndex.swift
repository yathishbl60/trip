#if !TRIP_STANDALONE
import TripDomain
#endif
import MapKit

/// Search the narrower coordinate band; longitude queries wrap at the antimeridian.
public nonisolated struct GeographicIndex: Sendable {
    private let horizontal: SortedMapAxis
    private let vertical: SortedMapAxis

    public init(_ places: [Place] = []) {
        let candidates = places.filter { $0.coordinate.isValid }.map(MapCandidate.init)
            .filter { $0.point.x.isFinite && $0.point.y.isFinite }
        horizontal = SortedMapAxis(candidates, axis: .horizontal)
        vertical = SortedMapAxis(candidates, axis: .vertical)
    }

    public func query(_ bounds: MKMapRect?, categories: Set<PlaceCategory>) -> [MapCandidate] {
        var matches: [MapCandidate] = []
        forEachCandidate(in: bounds, categories: categories) { matches.append($0) }
        return matches
    }

    func forEachCandidate(in bounds: MKMapRect?, categories: Set<PlaceCategory>, visit: (MapCandidate) -> Void) {
        guard let bounds else {
            for candidate in horizontal.items where categories.isEmpty || categories.contains(candidate.place.category) {
                visit(candidate)
            }
            return
        }
        guard bounds.minX.isFinite, bounds.minY.isFinite, bounds.maxX.isFinite, bounds.maxY.isFinite,
              bounds.width > 0, bounds.height > 0, !bounds.isNull else { return }
        for slice in candidateSlices(in: bounds) {
            for candidate in slice where candidate.isNearValidatedBounds(bounds)
                && (categories.isEmpty || categories.contains(candidate.place.category)) { visit(candidate) }
        }
    }

    private func candidateSlices(in bounds: MKMapRect) -> [ArraySlice<MapCandidate>] {
        let columns = ranges(bounds).map(horizontal.slice)
        let rows = vertical.slice(bounds.minY...bounds.maxY)
        return rows.count < columns.reduce(0, { $0 + $1.count }) ? [rows] : columns
    }

    private func ranges(_ rect: MKMapRect) -> [ClosedRange<Double>] {
        let world = MKMapSize.world.width
        guard rect.width < world else { return [0...world] }
        let start = (rect.minX.truncatingRemainder(dividingBy: world) + world).truncatingRemainder(dividingBy: world)
        let end = start + rect.width
        return end < world ? [start...end] : [start...world, 0...(end - world)]
    }

}
