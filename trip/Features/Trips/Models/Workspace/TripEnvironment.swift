import TripDomain
import AppIntents
import Foundation

/// The host decides where map actions lead. Standalone trips need no map state.
@MainActor struct TripEnvironment {
    var showExplore: () -> Void = {}
    var showPlace: (Place) -> Void = { _ in }
    var showDirections: (([Place]) -> Void)?
    var maximumRoutePlaces = 7
    var didOpenTrip: (TripPlan) -> Void = { _ in }
    var detailEntityIdentifier: (TripDetailIdentity) -> EntityIdentifier? = { _ in nil }
    var tripEntityIdentifier: (UUID) -> EntityIdentifier? = { _ in nil }
    var checklistEntityIdentifier: (TripChecklistIdentity) -> EntityIdentifier? = { _ in nil }
}
