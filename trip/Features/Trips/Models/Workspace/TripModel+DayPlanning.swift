import TripLocalization
import TripDomain
import Foundation

extension TripModel {
    func moveStop(_ stopID: UUID, from sourceID: UUID, to destinationID: UUID, tripID: UUID) {
        guard !tracking.isBusy, sourceID != destinationID, let trip = library.trip(tripID),
              let source = trip.days.firstIndex(where: { $0.id == sourceID }),
              let destination = trip.days.firstIndex(where: { $0.id == destinationID }),
              let stop = trip.days[source].stops.first(where: { $0.id == stopID }),
              canAdd(stop.place, to: trip.days[destination].stops, container: .day) else { return }
        let moved = library.update(tripID) { plan in
            plan.days[source].stops.removeAll { $0.id == stopID }
            plan.days[destination].stops.append(stop)
            return true
        }
        guard moved else { return }
        presentation.notice = nil
        feedback.show(TripText.movedToValue(trip.days[destination].title).text)
    }

    func moveDay(_ dayID: UUID, by offset: Int, tripID: UUID) {
        guard !tracking.isBusy, offset == -1 || offset == 1 else { return }
        library.update(tripID) { trip in
            guard let index = trip.days.firstIndex(where: { $0.id == dayID }),
                  trip.days.indices.contains(index + offset) else { return false }
            let original = trip
            trip.days.swapAt(index, index + offset)
            guard trip.preservesEventSpans(from: original) else {
                presentation.notice = TripText.thisMoveWouldChangeAMultiDayEventEdit.text
                return false
            }
            for index in trip.days.indices { trip.days[index].number = index + 1 }
            return true
        }
    }

    func beginSavedPlaces(dayID: UUID, tripID: UUID) {
        guard let trip = library.trip(tripID), trip.days.contains(where: { $0.id == dayID }) else { return }
        presentation.savedPlacePicker?.cancelSearch()
        presentation.savedPlacePicker = TripSavedPlacePickerModel(tripID: tripID, dayID: dayID)
        presentation.savedPlacePicker?.prepareSearch(in: trip)
    }

    func addSavedPlace(_ placeID: String, pickerID: UUID) {
        guard let picker = presentation.savedPlacePicker, picker.id == pickerID,
              let trip = library.trip(picker.tripID),
              let option = picker.savedPlaces(in: trip).first(where: { $0.id == placeID }) else { return }
        var stop = TripStop(place: option.stop.place)
        stop.notes = option.stop.notes
        stop.timing = option.stop.timing.unpinned
        addPickedStop(stop, picker: picker)
    }
    func addSearchPlace(_ place: Place, pickerID: UUID) {
        guard let picker = presentation.savedPlacePicker, picker.id == pickerID,
              picker.search.resolvedQuery == picker.searchTerm,
              picker.search.places.contains(where: { $0.id == place.id }) else { return }
        addPickedStop(TripStop(place: place), picker: picker)
    }
}
