import MapEngine
import TripDomain
import MapKit
import Foundation

extension ExploreModel {
    func selectNearbyPlace(_ place: Place) {
        history.record(.place(place))
        catalog.merge([place])
        navigatePlaceDetails(to: selection.detailPath + [.detail(place)])
    }

    func navigatePlaceDetails(to path: [PlaceDetailDestination]) {
        selection.navigate(to: path)
        layout.updateSelection(selectedPlace?.id)
        requestProjection()
    }

    func annotationChoices(for marker: MarkerModel) -> [Place] {
        let center = MKMapPoint(marker.place.coordinate.location)
        let radius = 20 * MKMapPointsPerMeterAtLatitude(marker.place.coordinate.latitude)
        let bounds = MKMapRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        let neighbors = discoveryIndex.query(bounds, categories: filters.effectiveCategories)
            .map(\.place).filter { $0.coordinate.distance(to: marker.place.coordinate) <= 20 }
        let places = [marker.place] + layout.choices(for: marker) + neighbors
        let unique = Dictionary(places.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        guard unique.count > 1 else { return [] }
        return unique.values.sorted {
            if ($0.id == marker.id) != ($1.id == marker.id) { return $0.id == marker.id }
            return $0.name == $1.name ? $0.id < $1.id : $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
}
