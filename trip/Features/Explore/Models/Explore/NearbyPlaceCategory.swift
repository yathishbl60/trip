import MapKit
import TripLocalization

nonisolated enum NearbyPlaceCategory: String, CaseIterable, Identifiable {
    case all, restaurants, cafes, groceries, attractions
    var id: String { rawValue }

    var title: TripText {
        switch self {
        case .all: .places
        case .restaurants: .restaurants
        case .cafes: .cafS
        case .groceries: .nearbyGroceries
        case .attractions: .attractions
        }
    }

    var categories: [MKPointOfInterestCategory]? {
        switch self {
        case .all: nil
        case .restaurants: [.restaurant]
        case .cafes: [.cafe]
        case .groceries: [.foodMarket]
        case .attractions: [.museum, .nationalPark, .park, .amusementPark, .zoo, .aquarium, .landmark]
        }
    }
}
