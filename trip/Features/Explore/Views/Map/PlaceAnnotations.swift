import MapEngine
import TripDomain
import MapKit
import SwiftUI

struct PlaceAnnotations: MapContent {
    let model: LayoutModel
    let controller: PlaceController
    var excludedIDs: Set<String> = []

    var body: some MapContent {
        ForEach(model.markers) { marker in
            if !excludedIDs.contains(marker.id) {
                Annotation(marker.place.name, coordinate: marker.place.coordinate.location, anchor: .center) {
                    NativePlaceAnnotationView(marker: marker, controller: controller)
                }
                .annotationTitles(.hidden)
                .tag(marker.id)
            }
        }
    }
}

#if DEBUG
#Preview("Native annotations · drag and pinch over photos") {
    ExploreMapView(controller: MapController(model: PreviewFixtures.explore(.street)))
}
#endif
