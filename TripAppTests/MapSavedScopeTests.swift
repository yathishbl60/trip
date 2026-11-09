import Testing
import TripDomain
import MapEngine
@testable import trip

@MainActor struct MapSavedScopeTests {
    @Test func savedScopeIncludesPlacesOutsideTheLiveCatalogAndFiltersLocally() async throws {
        let plan = MapRefinementFixtures.plan()
        let groups = [TripSavedPlaceGroup(plan)]
        let model = ExploreModel(provider: NavigationTestServices())
        model.chooseSavedScope(.trip(plan.id))
        await model.refreshSavedMap(SavedMapRequest(groups: groups, scope: .trip(plan.id), query: "Museum"))
        #expect(model.searchMatches.map(\.name) == ["Museum"])
        #expect(model.catalog.places.isEmpty && model.discoveryCounts[.museum] == 1)
        await model.refreshSavedMap(SavedMapRequest(groups: [], scope: .trip(plan.id), query: ""))
        #expect(model.savedMap.scope == .saved && model.searchMatches.isEmpty)
    }

    @Test func groupingDeduplicatesAcrossTripsAndKeepsPreviousStopIdentity() async throws {
        let first = MapRefinementFixtures.plan()
        var second = TripPlan(title: "Next trip")
        second.days[0].stops = first.days[0].stops
        let groups = [first, second].map(TripSavedPlaceGroup.init)
        let snapshot = try await SavedMapRequest(groups: groups, scope: .saved, query: "").snapshot()
        #expect(snapshot.places.count == 2)
        let previous = try #require(groups[0].previousStops.first)
        #expect(previous.id == first.days[0].stops[1].id && previous.place.name == "Hotel")
    }

    @Test func collectionBadgeOpensThatExactCollection() throws {
        var plan = MapRefinementFixtures.plan()
        var collection = TripCollection(title: "Coffee")
        collection.stops = [TripStop(place: MapRefinementFixtures.place("Cafe", category: .cafe))]
        plan.collections = [TripCollection(title: "Another list"), collection]
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [plan])
        let reference = try #require(model.explore.environment.savedPlaces("Cafe").first)
        model.explore.environment.openSavedPlace(reference)
        #expect(model.trips.presentation.detailRoute?.destination == .collection(collection.id))
        #expect(model.navigation.tab == .trips)
    }
}
