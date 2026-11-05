import TripDomain
import AppIntents

/// The host decides where map actions lead. Standalone trips need no map state.
@MainActor struct TripEnvironment {
    var showExplore: () -> Void = {}
    var showPlace: (Place) -> Void = { _ in }
    var showDirections: (([Place]) -> Void)?
    var maximumRoutePlaces = 7
    var didOpenTrip: (TripPlan) -> Void = { _ in }
    var detailEntityIdentifier: (TripDetailIdentity) -> EntityIdentifier? = { _ in nil }
}
