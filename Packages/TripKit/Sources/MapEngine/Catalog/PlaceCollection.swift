#if !TRIP_STANDALONE
import TripDomain
#endif
import Foundation

/// A value snapshot assembled on the repository actor before a single UI update.
public nonisolated struct PlaceCollection {
    private var indexed: [String: Place] = [:]
    private var names: [String: Set<String>] = [:]
    private var retained: Set<String> = []
    private var matched: Set<String> = []
    private let preservedID: String?
    private let policy: MapDataPolicy

    public init(_ places: [Place], preserving id: String? = nil, policy: MapDataPolicy = .init()) {
        preservedID = id
        self.policy = policy
        for place in places where place.coordinate.isValid { store(place) }
        if let id { retained.insert(id) }
    }

    public mutating func merge(_ incoming: [Place]) throws -> [Place] {
        try Task.checkCancellation()
        matched.removeAll(keepingCapacity: true)
        for place in incoming where place.coordinate.isValid {
            try Task.checkCancellation()
            let match = match(for: place)
            let updated = match?.updating(with: place) ?? place
            store(updated)
            retained.insert(updated.id)
            matched.insert(updated.id)
        }
        return Array(indexed.values.sorted(by: precedes).prefix(policy.placeLimit))
    }

    /// Canonical identities for this response, including matches to already loaded places.
    public var matchingPlaces: [Place] {
        Array(matched.compactMap { indexed[$0] }.sorted(by: precedes).prefix(policy.placeLimit))
    }

    private mutating func store(_ place: Place) {
        guard policy.nameMatchRadius != nil else {
            indexed[place.id] = place
            return
        }
        if let old = indexed[place.id] { names[old.matchingName]?.remove(place.id) }
        indexed[place.id] = place
        names[place.matchingName, default: []].insert(place.id)
    }

    private func match(for place: Place) -> Place? {
        if let exact = indexed[place.id] { return exact }
        guard let radius = policy.nameMatchRadius else { return nil }
        let name = place.matchingName
        guard !name.isEmpty else { return nil }
        var nearest: (place: Place, distance: Double)?
        for id in names[name, default: []] {
            guard let candidate = indexed[id] else { continue }
            let distance = candidate.coordinate.distance(to: place.coordinate)
            guard distance < radius else { continue }
            if let nearest, distance > nearest.distance
                || (distance == nearest.distance && candidate.id > nearest.place.id) { continue }
            nearest = (candidate, distance)
        }
        return nearest?.place
    }

    private func precedes(_ lhs: Place, _ rhs: Place) -> Bool {
        if (lhs.id == preservedID) != (rhs.id == preservedID) { return lhs.id == preservedID }
        if retained.contains(lhs.id) != retained.contains(rhs.id) { return retained.contains(lhs.id) }
        let left = lhs.importance.isFinite ? lhs.importance : 0
        let right = rhs.importance.isFinite ? rhs.importance : 0
        if left != right { return left > right }
        return lhs.id < rhs.id
    }
}
