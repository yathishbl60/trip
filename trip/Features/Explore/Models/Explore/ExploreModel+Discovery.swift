import TripDomain
import MapKit

extension ExploreModel {
    func discover(near place: Place) {
        catalog.cancelSearch()
        catalog.query = ""
        catalog.searchResults = nil
        filters.selected = Set([place.category]).intersection(filters.categories)
        select(nil)
        filterPlaces()
        camera.focus(place.coordinate)
        camera.region = MKCoordinateRegion(center: place.coordinate.location,
                                           latitudinalMeters: 2_400, longitudinalMeters: 2_400)
        scheduleSearch()
    }
}
