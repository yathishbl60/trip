import Foundation

enum AnnotationGalleryData {
    static let hotel = place("The Standard Bangkok", category: .hotel, rating: 4.7, reviews: 1_280)
    static let cafe = place("Roots at Sathon", category: .cafe, rating: 4.8, reviews: 386)
    static let park = place("Lumphini Park", category: .park, rating: 4.6, reviews: 12_400)
    static let longName = place("ลงแย๊กการโม · A very long local place name", category: .shopping, rating: 4.5, reviews: 12_400)
    static let unrated = place("Sukhumvit 1 Alley", category: .place, rating: nil, reviews: nil)

    private static func place(_ name: String, category: PlaceCategory, rating: Double?, reviews: Int?) -> Place {
        Place(id: name, name: name, coordinate: .bangkok, category: category, importance: 1, rating: rating, reviews: reviews)
    }
}
