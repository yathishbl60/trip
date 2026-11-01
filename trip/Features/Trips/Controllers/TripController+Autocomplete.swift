import Foundation
import SwiftUI

extension TripController {
    func choosePlaceSuggestion(_ id: String, picker: TripSavedPlacePickerModel) {
        guard model.presentation.savedPlacePicker?.id == picker.id else { return }
        picker.chooseSuggestion(id)
    }

    func retryPlaceSuggestions(_ picker: TripSavedPlacePickerModel) {
        guard model.presentation.savedPlacePicker?.id == picker.id else { return }
        picker.searchSuggestions()
    }

    func placeSearchPhaseChanged(_ phase: ScenePhase, picker: TripSavedPlacePickerModel) {
        guard model.presentation.savedPlacePicker?.id == picker.id else { return }
        if phase == .active { picker.searchRevision += 1 }
        else { picker.cancelSearch() }
    }
}
