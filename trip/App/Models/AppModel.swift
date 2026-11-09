import TripRouting
import Observation
import TripDomain
import AppIntents

/// The only owner of cross-feature composition and application navigation.
@MainActor @Observable final class AppModel {
    let explore: ExploreModel
    let trips: TripModel
    let navigation = AppNavigationModel()
    let system: AppSystemModel?

    init(explore: ExploreModel = ExploreModel(), trips: TripModel, system: AppSystemModel? = nil) {
        self.explore = explore
        self.trips = trips
        self.system = system
        connectFeatures()
    }

    func showExplore() { selectTab(.explore) }

    func showPlace(_ place: Place) {
        showExplore()
        explore.focus(place)
    }

    func showDayDirections(_ places: [Place]) {
        showExplore()
        explore.showDirections(for: places)
    }

    private func connectFeatures() {
        connectExplore()
        trips.environment = TripEnvironment(
            showExplore: { [weak self] in self?.showExplore() },
            showPlace: { [weak self] in self?.showPlace($0) },
            showDirections: { [weak self] in self?.showDayDirections($0) },
            maximumRoutePlaces: explore.directions.maximumPlaces,
            didOpenTrip: { [weak system] in system?.recordTripOpened($0) },
            detailEntityIdentifier: { EntityIdentifier(for: SavedTripDetailEntity.self, identifier: $0.rawValue) },
            tripEntityIdentifier: { EntityIdentifier(for: SavedTripEntity.self, identifier: $0) },
            checklistEntityIdentifier: { EntityIdentifier(for: SavedTripChecklistEntity.self, identifier: $0.rawValue) }
        )
    }
}
