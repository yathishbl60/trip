import Foundation

/// Removes duplicate listings while retaining separate branches and provider order.
public nonisolated enum PlaceSearchResults {
    public static func unique(_ places: [Place], limit: Int = 100) -> [Place] {
        guard limit > 0 else { return [] }
        var seenIDs: Set<String> = []
        var results: [Place] = []
        for place in places where place.coordinate.isValid {
            guard seenIDs.insert(place.id).inserted else { continue }
            guard !results.contains(where: { duplicates($0, place) }) else { continue }
            results.append(place)
            if results.count == limit { break }
        }
        return results
    }

    private static func duplicates(_ first: Place, _ second: Place) -> Bool {
        !first.matchingName.isEmpty && first.matchingName == second.matchingName
            && first.coordinate.distance(to: second.coordinate) < 5
    }
}
