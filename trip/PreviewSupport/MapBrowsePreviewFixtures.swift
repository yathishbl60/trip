#if DEBUG
import CoreGraphics
import MapEngine
import TripDomain

@MainActor enum MapBrowsePreviewFixtures {
    static func loaded(empty: Bool = false) -> ExploreModel {
        let model = PlaceDetailPreviewFixtures.saved()
        let places = empty ? [] : [PreviewFixtures.hotel, PreviewFixtures.longName, PreviewFixtures.unrated]
        let corners = [(14.0, 100.0), (14.0, 101.0), (13.0, 101.0), (13.0, 100.0)]
            .map { Coordinate(latitude: $0.0, longitude: $0.1).location }
        guard let region = MapCandidateRegion(corners: corners, center: Coordinate.bangkok.location) else { return model }
        model.catalog.merge(places)
        model.filterPlaces()
        model.browse.open()
        model.browse.refresh(index: GeographicIndex(places), categories: [], region: region, center: .bangkok,
                             sample: nil, size: CGSize(width: 390, height: 800))
        return model
    }
}
#endif
