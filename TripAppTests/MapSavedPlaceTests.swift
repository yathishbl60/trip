import Testing
import TripDomain
@testable import trip

@MainActor struct MapSavedPlaceTests {
    @Test func savedMapLinkOpensItsTripAndDeletedMembershipCannotNavigate() throws {
        var plan = TripPlan(title: "Weekend")
        let place = Place(id: "museum", name: "Museum", coordinate: .bangkok, category: .museum,
                          importance: 1, rating: nil, reviews: nil)
        plan.days[0].stops = [TripStop(place: place)]
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [plan])
        let reference = try #require(model.explore.environment.savedPlaces(place.id).first)
        model.explore.environment.openSavedPlace(reference)
        #expect(model.navigation.tab == .trips && model.trips.selectedTripID == plan.id)
        model.trips.library.remove(plan.id)
        model.request(.explore)
        model.explore.environment.openSavedPlace(reference)
        #expect(model.explore.environment.savedPlaces(place.id).isEmpty)
        #expect(model.navigation.tab == .explore)
        model.trips.library.saveTask?.cancel()
    }
}
