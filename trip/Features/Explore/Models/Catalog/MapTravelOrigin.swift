import Foundation
import TripDomain
import TripLocalization

nonisolated struct MapTravelOrigin: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let coordinate: Coordinate

    static func choices(groups: [TripSavedPlaceGroup], destinations: Set<String>) -> [Self] {
        var choices: [Self] = []
        for group in groups {
            choices += group.previousStops.filter { destinations.contains($0.destinationID) }.map {
                Self(id: $0.id.uuidString, title: TripText.previousStopValue($0.place.name).text,
                     subtitle: "\(group.title) · \($0.dayTitle)", coordinate: $0.place.coordinate)
            }
            choices += group.places.sorted { $0.category == .hotel && $1.category != .hotel }.map {
                Self(id: "\(group.id)/\($0.id)", title: $0.name, subtitle: group.title, coordinate: $0.coordinate)
            }
        }
        return choices.filter { $0.coordinate.isValid }
    }
}
