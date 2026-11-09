import MapKit
import SwiftUI
import Testing
import TripDomain
@testable import trip

@MainActor struct MapBrowsingContinuityTests {
    @Test func detailInspectionRestoresTheCameraAndRejectsIntermediateFrames() throws {
        let context = MapBrowseContext()
        let original = MapCamera(centerCoordinate: Coordinate.bangkok.location, distance: 4_000)
        let detail = MapCamera(centerCoordinate: Coordinate.bangkok.location, distance: 500)
        context.inspect(from: original)
        context.inspect(from: detail)
        #expect(try #require(context.returnCamera()).distance == 4_000)
        #expect(!context.accepts(detail))
        #expect(context.accepts(original))
        context.inspect(from: original)
        context.reset()
        #expect(context.returnCamera() == nil)
    }

    @Test func staleNavigationCannotReplaceANewSelection() {
        let model = ExploreModel(provider: NavigationTestServices())
        model.browseMap()
        model.selectPlace(MapRefinementFixtures.place("First"))
        let stale = MapBrowseController(model: model).path
        model.selectPlace(MapRefinementFixtures.place("Second"))
        stale.wrappedValue = []
        #expect(model.selectedPlace?.id == "Second")
        MapBrowseController(model: model).path.wrappedValue = []
        #expect(model.selectedPlace == nil && model.browse.isPresented)
    }

    @Test func nearbyCategoryAndDistanceSwitchesReuseTheirOwnCachedResults() async {
        let origin = MapRefinementFixtures.place("Origin")
        let cached = MapRefinementFixtures.place("Cached")
        let model = PlaceNearbySearchModel(origin: origin, results: [cached])
        model.choose(.close)
        #expect(model.places.isEmpty && model.isLoading)
        model.choose(.neighborhood)
        #expect(model.places == [cached] && !model.isLoading)
        model.choose(.cafes)
        #expect(model.places.isEmpty)
        model.choose(.all)
        await model.load()
        #expect(model.places == [cached] && !model.isLoading)
    }
}
