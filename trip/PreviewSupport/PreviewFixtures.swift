import TripDomain
import MapEngine
#if DEBUG
import MapKit
import SwiftUI

/// Local, repeatable preview content. Preview maps never schedule network searches.
@MainActor enum PreviewFixtures {
    static let hotel = Place(
        id: "preview-hotel", name: "SKYE Hotel Bangkok", coordinate: .bangkok,
        category: .hotel, importance: 1, rating: 4.7, reviews: 907
    )
    static let longName = Place(
        id: "preview-long", name: "ลงแย๊กการโม – Uncle Yae Souvenir Shop and Museum",
        coordinate: .bangkok, category: .shopping, importance: 1, rating: 4.5, reviews: 12_400
    )
    static let unrated = Place(
        id: "preview-unrated", name: "Sukhumvit 1 Alley", coordinate: .bangkok,
        category: .place, importance: 1, rating: nil, reviews: nil
    )

    static func place(_ category: PlaceCategory) -> Place {
        Place(id: "preview-\(category.rawValue)", name: category.title, coordinate: .bangkok,
              category: category, importance: 1, rating: 4.6, reviews: 1_200)
    }

    static func explore(_ zoom: ZoomLevel = .district,
                        categories: Set<PlaceCategory> = []) -> ExploreModel {
        let places = seeds()
        let model = ExploreModel(provider: LocalPlaceProvider(places: places))
        model.isActive = false
        model.camera.zoom = zoom
        model.camera.position = .camera(MapCamera(centerCoordinate: Coordinate.bangkok.location,
                                                  distance: zoom.distance))
        model.catalog.merge(places)
        model.catalog.hasLoaded = true
        model.filters.selected = categories
        model.filterPlaces()
        model.catalog.status = "Local preview collection"
        return model
    }

    static func searching() -> ExploreModel {
        let model = explore()
        model.catalog.isSearching = true
        return model
    }

    static func focused() -> ExploreModel {
        let model = explore()
        model.camera.focus(hotel.coordinate)
        return model
    }

    static func hotels() -> ExploreModel {
        var configuration = MapConfiguration()
        configuration.sourceName = "the local hotel collection"
        configuration.categories = [.hotel]
        configuration.showsLocation = false
        return ExploreModel(configuration: configuration, provider: LocalPlaceProvider(places: [hotel]))
    }

    static func searchResults() -> ExploreModel {
        let model = explore()
        model.catalog.query = hotel.name
        model.catalog.isSubmittedSearch = true
        model.catalog.searchResults = CatalogSnapshot([hotel])
        model.catalog.status = ""
        model.environment.savePlace = { _ in }
        return model
    }

    static func offline() -> ExploreModel {
        let model = explore()
        model.catalog.status = model.catalog.searchFailureMessage
        model.catalog.canRetrySearch = true
        return model
    }

    static func noMatches() -> ExploreModel {
        let model = explore()
        model.catalog.query = "An unmatched place"
        model.catalog.isSubmittedSearch = true
        let update = CatalogSearchUpdate(catalog: CatalogSnapshot(model.catalog.places), matches: CatalogSnapshot([]))
        model.catalog.acceptSearch(update, query: model.catalog.query)
        model.filterPlaces()
        return model
    }

    private static func seeds() -> [Place] {
        guard let url = Bundle.main.url(forResource: "Places", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let places = try? JSONDecoder().decode([Place].self, from: data) else { return [hotel] }
        return places
    }
}
#endif
