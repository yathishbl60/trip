#if !TRIP_STANDALONE
import TripLocalization
#endif
#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import Foundation

/// Configure a feature at its composition root; the Bangkok experience is the default.
nonisolated struct MapConfiguration: Sendable {
    var initialCenter: Coordinate = .bangkok
    var initialDistance = ZoomLevel.district.distance
    var startingPointLabel = TripText.bangkokStartingPoint.text
    var sourceName = TripText.appleMaps.text
    var categories = PlaceCategory.allCases
    var initialCategories: Set<PlaceCategory> = []
    var showsLocation = true
    var showsFilters = true
    var showsTrips = true
    var layout = MarkerLayoutPolicy()
    var motion = MapMotion()
    var data = MapDataPolicy()

    var validCenter: Coordinate { initialCenter.isValid ? initialCenter : .bangkok }
    var validDistance: Double { CameraNavigationPolicy.clampedDistance(initialDistance) }
    var availableCategories: [PlaceCategory] {
        let selected = Set(categories)
        return PlaceCategory.allCases.filter { selected.isEmpty || selected.contains($0) }
    }
}
