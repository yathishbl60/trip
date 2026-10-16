import Foundation

/// Geographic insertion ranking; never presented as a road distance or travel time.
public nonisolated struct TripPlaceInsertion: Identifiable, Sendable {
    public var id: UUID { dayID }
    public let dayID: UUID
    public let index: Int
    public let nearbyName: String?
    public let distance: Double?

    public static func suggestions(for place: Place, in trip: TripPlan) -> [Self] {
        trip.days.compactMap { best(for: place, in: $0) }.sorted {
            ($0.distance ?? .infinity) < ($1.distance ?? .infinity)
        }
    }

    public static func best(for place: Place, in day: TripDay) -> Self? {
        guard TripStopAvailability(placeID: place.id, stops: day.stops) == .available else { return nil }
        let candidates = (0...day.stops.count).map { candidate(place, day: day, index: $0) }
        guard candidates.contains(where: { $0.distance != nil }) else {
            return Self(dayID: day.id, index: day.stops.count, nearbyName: nil, distance: nil)
        }
        return candidates.enumerated().min {
            let lhs = $0.element.distance ?? .infinity
            let rhs = $1.element.distance ?? .infinity
            return lhs == rhs ? $0.offset < $1.offset : lhs < rhs
        }?.element
    }

    private static func nearbyName(_ neighbor: Place?, to place: Place) -> String? {
        guard let neighbor, neighbor.coordinate.distance(to: place.coordinate) <= 5_000 else { return nil }
        return neighbor.name
    }

    private static func candidate(_ place: Place, day: TripDay, index: Int) -> Self {
        let before = index > 0 ? day.stops[index - 1].place : nil
        let after = index < day.stops.count ? day.stops[index].place : nil
        let neighbors = [before, after].compactMap { $0 }
        guard place.coordinate.isValid, !neighbors.isEmpty,
              neighbors.allSatisfy({ $0.coordinate.isValid }) else {
            return Self(dayID: day.id, index: index, nearbyName: nil, distance: nil)
        }
        let added = neighbors.reduce(0) { $0 + place.coordinate.distance(to: $1.coordinate) }
        let replaced = before.flatMap { first in after.map { first.coordinate.distance(to: $0.coordinate) } } ?? 0
        let nearest = neighbors.min { place.coordinate.distance(to: $0.coordinate) < place.coordinate.distance(to: $1.coordinate) }
        return Self(dayID: day.id, index: index, nearbyName: nearbyName(nearest, to: place), distance: max(0, added - replaced))
    }
}
