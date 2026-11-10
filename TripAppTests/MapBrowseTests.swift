import CoreGraphics
import MapKit
import MapEngine
import SwiftUI
import Testing
import TripDomain
@testable import trip

@MainActor struct MapBrowseTests {
    @Test func browsingIncludesMoreThanSuggestionsAndUsesExactViewportAndFilters() async throws {
        let places = (0..<40).map { place("museum-\($0)", longitude: 100.5 + Double($0) / 1_000) }
        let outside = place("outside", longitude: 103)
        let cafe = place("cafe", longitude: 100.5, category: .cafe)
        let corners = [(14.0, 100.0), (14.0, 101.0), (13.0, 101.0), (13.0, 100.0)]
            .map { Coordinate(latitude: $0.0, longitude: $0.1).location }
        let region = try #require(MapCandidateRegion(corners: corners, center: places[0].coordinate.location))
        let items = try await MapBrowseItem.load(index: GeographicIndex(places + [outside, cafe, places[0]]),
                                                region: region, categories: [.museum], center: places[0].coordinate)
        #expect(items.count == 40 && Set(items.map(\.id)).count == 40)
        #expect(items.first?.id == places[0].id && items.first?.distance == 0)
        #expect(zip(items, items.dropFirst()).allSatisfy { $0.distance <= $1.distance })
    }

    @Test func staleDismissalCannotCloseAReopenedResultsSheet() {
        let model = ExploreModel(provider: NavigationTestServices())
        model.browseMap()
        let oldSheet = PlaceController(model: model).mapSheet
        model.dismissMapSheet()
        model.browseMap()
        oldSheet.wrappedValue = nil
        #expect(model.browse.isPresented && model.mapSheet == .details)
        PlaceController(model: model).mapSheet.wrappedValue = nil
        #expect(!model.browse.isPresented && model.mapSheet == nil)
    }

    @Test func saveFromResultsUsesTheExistingDetailSheetHost() {
        let model = ExploreModel(provider: NavigationTestServices())
        let place = place("saved")
        var selectedAtSave: String?
        model.environment.savePlace = { _ in selectedAtSave = model.selectedPlace?.id }
        model.browseMap()
        PlaceController(model: model).save(place)
        #expect(selectedAtSave == place.id && model.browse.isPresented)
        model.returnToResults()
        #expect(model.selectedPlace == nil && model.mapSheet == .details)
        model.environment.savePlace = nil
    }

    @Test func nearbyCategoryChangeInvalidatesThePreviousResults() {
        let origin = place("origin")
        let model = PlaceNearbySearchModel(origin: origin, results: [place("old")])
        model.choose(.groceries)
        #expect(model.category == .groceries && model.places.isEmpty && model.error == nil)
        #expect(model.isLoading && model.retryRevision == 1)
        model.choose(.groceries)
        #expect(model.retryRevision == 1)
    }

    private func place(_ id: String, longitude: Double = 100.5, category: PlaceCategory = .museum) -> Place {
        Place(id: id, name: id, coordinate: Coordinate(latitude: 13.5, longitude: longitude),
              category: category, importance: 1, rating: nil, reviews: nil)
    }
}
