import MapEngine
import TripDomain
#if DEBUG
import Foundation

extension PreviewFixtures {
    static func dense() -> ExploreModel {
        let model = explore(.district)
        let places = (0..<2_000).map(densePlace)
        model.catalog.merge(places)
        model.filterPlaces()
        return model
    }

    private static func densePlace(_ index: Int) -> Place {
        let category = PlaceCategory.allCases[index % PlaceCategory.allCases.count]
        let importance = Double(index % 100) / 100
        return Place(id: "dense-\(index)", name: "Bangkok place \(index + 1)",
                     coordinate: denseCoordinate(index), category: category,
                     importance: importance, rating: 4.5, reviews: 500)
    }

    private static func denseCoordinate(_ index: Int) -> Coordinate {
        let latitude = Coordinate.bangkok.latitude + Double(index % 43) / 2_000 - 0.01
        let longitude = Coordinate.bangkok.longitude + Double(index % 47) / 2_000 - 0.01
        return Coordinate(latitude: latitude, longitude: longitude)
    }
}
#endif
