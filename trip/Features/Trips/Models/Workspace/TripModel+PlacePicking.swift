import TripLocalization
import Foundation
import TripDomain

extension TripModel {
    func reconcilePlacePicker(_ picker: TripSavedPlacePickerModel) {
        guard presentation.savedPlacePicker?.id == picker.id else { return }
        guard let trip = library.trip(picker.tripID) else {
            picker.cancelSearch()
            picker.lastAddition = nil
            return
        }
        if !trip.days.contains(where: { $0.id == picker.dayID }), let day = trip.days.first {
            picker.selectDay(day.id, in: trip)
            picker.notice = TripText.thePreviousDayWasRemovedNowAddingToValue(day.title).text
        }
        if let addition = picker.lastAddition,
           trip.days.first(where: { $0.id == addition.dayID })?.stops.contains(addition.stop) != true {
            picker.lastAddition = nil
        }
    }

    func addPickedStop(_ stop: TripStop, picker: TripSavedPlacePickerModel) {
        let saved = library.updateDay(picker.dayID, in: picker.tripID) { day in
            guard TripStopAvailability(placeID: stop.place.id, stops: day.stops) == .available else { return false }
            day.stops.append(stop)
            picker.lastAddition = TripPlaceAddition(stop: stop, dayID: day.id, dayTitle: day.title)
            return true
        }
        picker.notice = saved ? nil : TripText.thisDayChangedThePlaceMayAlreadyBeSaved.text
    }

    func undoPickedPlace(_ picker: TripSavedPlacePickerModel) {
        guard presentation.savedPlacePicker?.id == picker.id, let addition = picker.lastAddition,
              !tracking.isBusy else { return }
        let removed = library.updateDay(addition.dayID, in: picker.tripID) { day in
            guard day.stops.contains(addition.stop) else { return false }
            day.stops.removeAll { $0.id == addition.stop.id }
            day.itemOrder.removeAll { $0 == addition.stop.id }
            return true
        }
        picker.lastAddition = nil
        picker.notice = removed ? nil : TripText.thisPlaceChangedAfterItWasAddedReviewIt.text
    }
}
