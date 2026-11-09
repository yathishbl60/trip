import TripDomain

/// Host actions keep Explore independent of trip storage and app navigation.
@MainActor struct ExploreEnvironment {
    var savePlace: ((Place) -> Void)?
    var dismissSave: () -> Void = {}
    var isSavingPlace: () -> Bool = { false }
    var savedPlaces: (String) -> [TripSavedPlaceReference] = { _ in [] }
    var openSavedPlace: (TripSavedPlaceReference) -> Void = { _ in }
}
