import TripLocalization
import TripDomain
import Foundation

nonisolated enum TripSortOrder { case recent, departure }

extension TripLibraryModel {
    func filteredTrips(query searchQuery: String, sortOrder: TripSortOrder) -> [TripPlan] {
        let query = PlaceSearchQuery(searchQuery)
        let matchingTrips = trips.filter { query.isEmpty || matches($0, query: query) }
        return matchingTrips.sorted {
            if sortOrder == .departure, $0.startDate != $1.startDate {
                return $0.startDate < $1.startDate
            }
            if sortOrder == .recent, $0.createdAt != $1.createdAt {
                return $0.createdAt > $1.createdAt
            }
            return $0.title.localizedStandardCompare($1.title) == .orderedAscending
        }
    }

    private func matches(_ trip: TripPlan, query: PlaceSearchQuery) -> Bool {
        let fields = [trip.title, trip.notes] + trip.days.map(\.title) + trip.collections.map(\.title)
            + trip.savedPlaces.flatMap(\.searchFields) + trip.checklist.map(\.title)
        let eventFields = trip.events.flatMap { [$0.title, $0.kind.title, $0.location, $0.arrivalLocation, $0.notes] }
        return query.matches(fields + eventFields)
    }

    var savedPlaceCount: Int { trips.reduce(0) { $0 + $1.savedPlaces.count } }
    var tripCountText: String { TripText.tripCount(trips.count).text }
    var savedPlaceCountText: String { TripText.savedPlaceCount(savedPlaceCount).text }

    func duplicate(_ trip: TripPlan) {
        insert(TripPlan(copying: trip))
    }
}
