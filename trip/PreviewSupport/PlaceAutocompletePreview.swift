#if DEBUG
import TripDomain

enum PlaceAutocompletePreview {
    /// Illustrates multiple rows; actual suggestions are supplied by Apple Maps.
    static let suggestions = [
        PlaceSearchSuggestion(title: "Phuket", subtitle: "Thailand"),
        PlaceSearchSuggestion(title: "Philadelphia", subtitle: "Pennsylvania, United States"),
        PlaceSearchSuggestion(title: "Philippines", subtitle: "Country")
    ]
}
#endif
