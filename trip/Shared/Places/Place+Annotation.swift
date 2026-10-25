import TripLocalization
#if !TRIP_STANDALONE
import TripDomain
#endif
import Foundation

extension Place {
    var hasAnnotationPhoto: Bool { !isLive && category != .place }
    var annotationRatingText: String { rating == nil ? TripText.viewDetails.text : ratingText }
    var annotationRatingSymbol: String { rating == nil ? "chevron.right" : "star.fill" }
}

extension PlaceCategory {
    var annotationTitle: String {
        switch self {
        case .restaurant: TripText.restaurant.text
        case .cafe: TripText.cafe.text
        case .bar: TripText.bar.text
        case .attraction: TripText.attraction.text
        case .park: TripText.park.text
        case .entertainment: TripText.entertainment.text
        case .museum: TripText.museum.text
        case .shopping: TripText.shopping.text
        case .hotel: TripText.hotel.text
        case .place: TripText.place.text
        }
    }
}
