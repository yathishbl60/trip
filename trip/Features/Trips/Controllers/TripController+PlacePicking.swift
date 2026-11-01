import Foundation
import SwiftUI
import TripDomain

extension TripController {
    func placePickerDay(_ picker: TripSavedPlacePickerModel) -> Binding<UUID> {
        Binding(get: { picker.dayID }, set: { id in
            guard model.presentation.savedPlacePicker?.id == picker.id,
                  let trip = model.library.trip(picker.tripID) else { return }
            picker.selectDay(id, in: trip)
        })
    }

    func searchSuggestion(_ query: String, picker: TripSavedPlacePickerModel) {
        guard model.presentation.savedPlacePicker?.id == picker.id else { return }
        picker.setQuery(query)
    }

    func undoPickedPlace(_ picker: TripSavedPlacePickerModel) { model.undoPickedPlace(picker) }
    func reconcilePlacePicker(_ picker: TripSavedPlacePickerModel) { model.reconcilePlacePicker(picker) }
}
