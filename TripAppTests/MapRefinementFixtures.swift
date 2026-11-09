import TripDomain
@testable import trip

@MainActor enum MapRefinementFixtures {
    static func place(_ id: String, category: PlaceCategory = .museum) -> Place {
        Place(id: id, name: id, coordinate: .bangkok, category: category, importance: 1, rating: nil, reviews: nil)
    }

    static func plan() -> TripPlan {
        var plan = TripPlan(title: "Weekend")
        plan.days[0].stops = [TripStop(place: place("Hotel", category: .hotel)), TripStop(place: place("Museum"))]
        return plan
    }
}
