#if DEBUG
import Foundation
import TripDomain

@MainActor enum PlaceDetailPreviewFixtures {
    static func saving() -> ExploreModel {
        let model = PreviewFixtures.explore()
        model.environment.savePlace = { _ in }
        return model
    }

    static func saved() -> ExploreModel {
        let model = saving()
        var plan = TripPlan(title: "Bangkok weekend")
        plan.days[0].stops = [TripStop(place: PreviewFixtures.hotel)]
        let index = TripSavedPlaceIndex([plan])
        model.environment.savedPlaces = { index.places($0) }
        return model
    }

    static let live = Place(id: "preview-live", name: "The Grand Palace", coordinate: .bangkok,
        category: .attraction, importance: 1, rating: nil, reviews: nil,
        address: "Na Phra Lan Road, Phra Borom Maha Ratchawang, Phra Nakhon, Bangkok 10200, Thailand",
        website: URL(string: "https://www.royalgrandpalace.th/"), isLive: true)
}
#endif
