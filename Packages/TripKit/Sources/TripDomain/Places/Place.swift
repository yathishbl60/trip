#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated struct Place: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let coordinate: Coordinate
    public let category: PlaceCategory
    public let importance: Double
    public let rating: Double?
    public let reviews: Int?
    public var address: String?
    public var website: URL?
    public var phoneNumber: String?
    public var isLive = false
    public var mapItemIdentifier: String?

    public init(id: String, name: String, coordinate: Coordinate, category: PlaceCategory,
                importance: Double, rating: Double?, reviews: Int?, address: String? = nil,
                website: URL? = nil, phoneNumber: String? = nil, isLive: Bool = false, mapItemIdentifier: String? = nil) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.category = category
        self.importance = importance
        self.rating = rating
        self.reviews = reviews
        self.address = address
        self.website = website
        self.phoneNumber = phoneNumber
        self.isLive = isLive
        self.mapItemIdentifier = mapItemIdentifier
    }

    public var matchingName: String {
        name.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .filter { $0.isLetter || $0.isNumber }
    }

    public func updating(with other: Self) -> Self {
        Self(id: id, name: other.name, coordinate: other.coordinate, category: other.category,
             importance: max(importance, other.importance), rating: rating, reviews: reviews,
             address: other.address, website: other.website, phoneNumber: other.phoneNumber, isLive: other.isLive,
             mapItemIdentifier: other.mapItemIdentifier ?? mapItemIdentifier)
    }

    public var ratingText: String {
        rating?.formatted(.number.precision(.fractionLength(1))) ?? ""
    }

    public var reviewText: String {
        guard let reviews else { return "" }
        let number = reviews.formatted(.number.notation(.compactName).precision(.fractionLength(0...1)))
        return "(\(number))"
    }

    public var accessibilityLabel: String {
        guard rating != nil else { return "\(name), \(category.title)" }
        return TripText.placeSampleAccessibility(name, category.title, ratingText).text
    }

    public var mapsURL: URL? {
        var parts = URLComponents(string: "https://maps.apple.com/")
        parts?.queryItems = [
            URLQueryItem(name: "ll", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "q", value: name)
        ]
        return parts?.url
    }

    public var nearbyTitle: String { TripText.nearbyPlaces.text }
}
