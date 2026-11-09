import TripDomain

extension PlaceController {
    func savedPlaces(_ place: Place) -> [TripSavedPlaceReference] { model.environment.savedPlaces(place.id) }
    func isSaved(_ place: Place) -> Bool { !savedPlaces(place).isEmpty }
    func openSavedPlace(_ reference: TripSavedPlaceReference) { model.environment.openSavedPlace(reference) }
}
