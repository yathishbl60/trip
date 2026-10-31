import Foundation
import Observation
import TripDomain

@MainActor @Observable final class TripTimeZoneSearchModel {
    var query = ""
    private let identifiers = TimeZone.knownTimeZoneIdentifiers.sorted()
    private let names = TripTimeZoneSearchModel.searchableNames()
    var results: [String] {
        let search = PlaceSearchQuery(query)
        guard !search.isEmpty else { return identifiers }
        return identifiers.filter { search.matches(names[$0] ?? [$0]) }
    }

    func title(_ zoneID: String) -> String { zoneID.replacingOccurrences(of: "_", with: " ") }

    private static func searchableNames() -> [String: [String]] {
        Dictionary(uniqueKeysWithValues: TimeZone.knownTimeZoneIdentifiers.map { identifier in
            let zone = TimeZone(identifier: identifier)
            return (identifier, [identifier, zone?.localizedName(for: .standard, locale: .current) ?? "",
                                 zone?.localizedName(for: .shortStandard, locale: .current) ?? ""])
        })
    }
}
