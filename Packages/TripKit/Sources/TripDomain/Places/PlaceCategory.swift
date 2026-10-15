#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated enum PlaceCategory: String, CaseIterable, Codable, Identifiable, Sendable {
    case restaurant, cafe, bar, attraction, park, entertainment, museum, shopping, hotel, place
    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .restaurant: TripText.restaurants.text
        case .cafe: TripText.cafS.text
        case .bar: TripText.bars.text
        case .attraction: TripText.attractions.text
        case .park: TripText.parks.text
        case .entertainment: TripText.entertainment.text
        case .museum: TripText.museums.text
        case .shopping: TripText.shopping.text
        case .hotel: TripText.hotels.text
        case .place: TripText.places.text
        }
    }

    public var symbol: String {
        switch self {
        case .restaurant: "fork.knife"
        case .cafe: "cup.and.saucer"
        case .bar: "wineglass"
        case .attraction: "star"
        case .park: "tree"
        case .entertainment: "theatermasks"
        case .museum: "building.columns"
        case .shopping: "bag"
        case .hotel: "bed.double"
        case .place: "mappin"
        }
    }

    public var photoName: String { "Sample-" + rawValue }
}
