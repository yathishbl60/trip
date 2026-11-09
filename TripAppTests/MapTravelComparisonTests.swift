import Testing
import TripDomain
import TripRouting
@testable import trip

@MainActor struct MapTravelComparisonTests {
    @Test func modeChangesRejectLateEstimatesAndReuseOnlyMatchingCacheEntries() async throws {
        let service = ControlledTravelTimes()
        let model = comparison(service)
        let first = Task { await model.load() }
        await service.waitForRequest(0)
        first.cancel()
        model.mode = .driving
        let second = Task { await model.load() }
        await service.waitForRequest(1)
        service.finish(1, seconds: 120)
        await second.value
        service.finish(0, seconds: 900)
        await first.value
        #expect(model.estimates["Museum"]?.travelTime == 120)
        await model.load()
        #expect(service.modes == [.walking, .driving])
    }

    @Test func comparisonNeverSelectsMoreThanThreePlaces() {
        let places = (0..<5).map { MapRefinementFixtures.place("Place \($0)") }
        let model = MapTravelComparisonModel(places: places, groups: [])
        for place in places { model.toggle(place) }
        #expect(model.selected.count == 3)
        model.toggle(places[0])
        model.toggle(places[4])
        #expect(model.selected.contains(places[4].id) && model.selected.count == 3)
    }

    private func comparison(_ provider: ControlledTravelTimes) -> MapTravelComparisonModel {
        let plan = MapRefinementFixtures.plan()
        let model = MapTravelComparisonModel(places: plan.savedPlaces, groups: [TripSavedPlaceGroup(plan)], provider: provider)
        model.toggle(plan.days[0].stops[1].place)
        model.originID = model.origins.first!.id
        return model
    }
}
