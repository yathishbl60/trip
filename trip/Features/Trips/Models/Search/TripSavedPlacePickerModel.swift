import TripDomain
import Observation
import Foundation

@MainActor @Observable final class TripSavedPlacePickerModel: Identifiable {
    let id = UUID()
    let tripID: UUID
    private(set) var dayID: UUID
    let search: TripPlaceSearchModel
    let autocomplete = PlaceAutocompleteModel()
    var isSubmittedSearch = false
    var suggestionID: String?
    private(set) var searchOrigin: Place?
    var lastAddition: TripPlaceAddition?
    var query = ""
    var notice: String?
    var searchRevision = 0
    var searchTaskID: String { "\(dayID):\(searchRevision):\(isSubmittedSearch):\(searchTerm)" }
    var searchTerm: String { PlaceSearchQuery(query).text }

    init(tripID: UUID, dayID: UUID, search: TripPlaceSearchModel = .init()) {
        self.tripID = tripID
        self.dayID = dayID
        self.search = search
    }

    func setQuery(_ value: String) {
        guard query != value else { return }
        if searchTerm != PlaceSearchQuery(value).text {
            isSubmittedSearch = false
            suggestionID = nil
            autocomplete.cancel()
            search.prepare(PlaceSearchQuery(value).text)
        }
        if searchOrigin == nil, let addition = lastAddition, addition.dayID == dayID,
           addition.stop.place.coordinate.isValid { searchOrigin = addition.stop.place }
        query = value
    }

    func selectDay(_ id: UUID, in trip: TripPlan) {
        guard dayID != id, trip.days.contains(where: { $0.id == id }) else { return }
        search.clear()
        autocomplete.cancel()
        isSubmittedSearch = false
        suggestionID = nil
        dayID = id
        notice = nil
        prepareSearch(in: trip)
    }

    func prepareSearch(in trip: TripPlan) {
        let day = trip.days.first { $0.id == dayID }
        searchOrigin = day?.stops.last { $0.place.coordinate.isValid }?.place
            ?? trip.savedPlaces.first { $0.coordinate.isValid }
    }

}

struct TripSavedPlaceOption: Identifiable {
    let stop: TripStop
    let source: String
    var id: String { stop.place.id }
}
