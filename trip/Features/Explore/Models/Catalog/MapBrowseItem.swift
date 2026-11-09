import Foundation
import MapEngine
import TripDomain

nonisolated struct MapBrowseItem: Identifiable, Sendable {
    let place: Place
    let distance: Double
    var id: String { place.id }
    var distanceText: String {
        Measurement(value: distance, unit: UnitLength.meters).formatted(.measurement(width: .abbreviated, usage: .road))
    }

    @concurrent static func load(index: GeographicIndex, region: MapCandidateRegion,
                                categories: Set<PlaceCategory>, center: Coordinate) async throws -> [Self] {
        var seen: Set<String> = []
        var items: [Self] = []
        for candidate in index.query(region.bounds, categories: categories) {
            try Task.checkCancellation()
            guard region.contains(candidate.point), seen.insert(candidate.place.id).inserted else { continue }
            items.append(Self(place: candidate.place, distance: candidate.place.coordinate.distance(to: center)))
        }
        return items.sorted { ($0.distance, $0.id) < ($1.distance, $1.id) }
    }
}
