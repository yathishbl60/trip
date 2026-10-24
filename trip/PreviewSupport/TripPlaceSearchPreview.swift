#if DEBUG
import TripDomain

enum TripPlaceSearchPreview {
    static func picker(in model: TripModel, dayIndex: Int = 0, query: String = "", places: [Place] = [],
                       error: String? = nil, isSearching: Bool = false) -> TripSavedPlacePickerModel {
        let trip = model.library.trips[0]
        let search = TripPlaceSearchModel(places: places, query: query, error: error,
                                         isSearching: isSearching, allowsLiveSearch: false)
        let picker = TripSavedPlacePickerModel(tripID: trip.id, dayID: trip.days[dayIndex].id, search: search)
        picker.query = query
        picker.isSubmittedSearch = !query.isEmpty
        picker.prepareSearch(in: trip)
        model.presentation.savedPlacePicker = picker
        return picker
    }
}
#endif
