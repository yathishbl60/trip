import TripDomain
import MapKit

extension PlaceCategory {
    public var mapCategories: [MKPointOfInterestCategory] {
        switch self {
        case .restaurant: [.restaurant, .bakery, .foodMarket]
        case .cafe: [.cafe]
        case .bar: [.nightlife, .brewery, .winery]
        case .attraction: [.landmark, .nationalMonument, .castle]
        case .park: [.park, .nationalPark, .beach]
        case .entertainment: [.theater, .movieTheater, .amusementPark, .stadium]
        case .museum: [.museum]
        case .shopping: [.store]
        case .hotel: [.hotel]
        case .place: [.hospital, .school, .university, .conventionCenter]
        }
    }

    static func resolve(_ category: MKPointOfInterestCategory?) -> Self {
        allCases.first { $0.mapCategories.contains { $0 == category } } ?? .place
    }
}
