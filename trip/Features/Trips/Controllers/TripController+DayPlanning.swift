import TripDomain
import SwiftUI

extension TripController {
    func savedPlacePicker(forAssistant: Bool) -> Binding<TripSavedPlacePickerModel?> {
        let currentID = model.presentation.savedPlacePicker?.id
        return Binding(get: {
            guard (model.presentation.assistantTripID != nil) == forAssistant else { return nil }
            return model.presentation.savedPlacePicker
        }, set: { value in
            guard value == nil, model.presentation.savedPlacePicker?.id == currentID,
                  (model.presentation.assistantTripID != nil) == forAssistant else { return }
            model.presentation.savedPlacePicker?.cancelSearch()
            model.presentation.savedPlacePicker = nil
        })
    }

    func savedPlacesSearch(_ picker: TripSavedPlacePickerModel) -> Binding<String> {
        Binding(get: { picker.query }, set: { query in
            guard model.presentation.savedPlacePicker?.id == picker.id, picker.query != query else { return }
            picker.setQuery(query)
        })
    }

    func beginSavedPlaces(dayID: UUID, tripID: UUID) {
        model.beginSavedPlaces(dayID: dayID, tripID: tripID)
    }

    func closeSavedPlaces(_ pickerID: UUID) {
        guard model.presentation.savedPlacePicker?.id == pickerID else { return }
        model.presentation.savedPlacePicker?.cancelSearch()
        model.presentation.savedPlacePicker = nil
    }

    func addSavedPlace(_ placeID: String, pickerID: UUID) {
        model.addSavedPlace(placeID, pickerID: pickerID)
    }

    func searchPlaces(_ picker: TripSavedPlacePickerModel) async {
        guard model.presentation.savedPlacePicker?.id == picker.id,
              let trip = model.library.trip(picker.tripID) else { return }
        guard trip.days.contains(where: { $0.id == picker.dayID }) else { picker.cancelSearch(); return }
        guard picker.isSubmittedSearch else { picker.searchSuggestions(); return }
        await picker.search.search(picker.searchTerm, near: picker.searchOrigin?.coordinate,
                                   suggestionID: picker.suggestionID, autocomplete: picker.autocomplete)
    }

    func retryPlaceSearch(_ picker: TripSavedPlacePickerModel) { picker.submitSearch() }
    func addSearchPlace(_ place: Place, pickerID: UUID) { model.addSearchPlace(place, pickerID: pickerID) }

    func moveStop(_ stopID: UUID, from sourceID: UUID, to destinationID: UUID, tripID: UUID) {
        model.moveStop(stopID, from: sourceID, to: destinationID, tripID: tripID)
    }

    func moveDay(_ dayID: UUID, by offset: Int, tripID: UUID) {
        model.moveDay(dayID, by: offset, tripID: tripID)
    }
}
