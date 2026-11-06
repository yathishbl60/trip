import TripLocalization
#if !TRIP_STANDALONE
import TripDomain
#endif
import Foundation

extension Place {
    /// The app bundles no place photographs; saved/sample places use category artwork too.
    var hasAnnotationPhoto: Bool { false }
    var annotationSubtitle: String { rating == nil ? category.annotationTitle : ratingText }
    var annotationSubtitleSymbol: String { rating == nil ? category.symbol : "star.fill" }
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
