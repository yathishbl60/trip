import TripDomain
import Foundation

extension TripSavedPlacePickerModel {
    func options(in trip: TripPlan) -> [TripSavedPlaceOption] {
        let query = PlaceSearchQuery(searchTerm)
        return savedPlaces(in: trip).filter { query.matches($0.stop.place.searchFields + [$0.source]) }
    }

    func savedPlaces(in trip: TripPlan) -> [TripSavedPlaceOption] {
        var seen: Set<String> = []
        let collections = trip.collections.flatMap { collection in
            collection.stops.map { TripSavedPlaceOption(stop: $0, source: collection.title) }
        }
        let days = trip.days.filter { $0.id != dayID }.flatMap { day in
            day.stops.map { TripSavedPlaceOption(stop: $0, source: day.title) }
        }
        return (collections + days).filter { seen.insert($0.id).inserted }
    }

    func mapPlaces(in trip: TripPlan) -> [Place] {
        guard search.resolvedQuery == searchTerm else { return [] }
        let saved = Set(options(in: trip).map(\.id))
        return search.places.filter { !saved.contains($0.id) }
    }

    func showsMapSearch(in trip: TripPlan) -> Bool {
        search.isSearching || search.error != nil || search.resolvedQuery != searchTerm
            || !mapPlaces(in: trip).isEmpty || options(in: trip).isEmpty
    }
}
