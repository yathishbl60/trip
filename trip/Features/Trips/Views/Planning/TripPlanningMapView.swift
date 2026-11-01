import SwiftUI
import MapKit
import TripDomain
import TripLocalization

struct TripPlanningMapView: View {
    let draft: TripPlanningDraft

    var body: some View {
        Map(initialPosition: .automatic) {
            ForEach(draft.routes.segments) { segment in
                if let route = segment.route {
                    MapPolyline(route.polyline).stroke(AppTheme.accent, lineWidth: 4)
                } else if segment.isLocated {
                    MapPolyline(coordinates: segment.coordinates)
                        .stroke(.secondary, style: StrokeStyle(lineWidth: 2, dash: [4, 5]))
                }
            }
            ForEach(draft.mapPins) { pin in
                Marker(pin.title, coordinate: pin.stop.place.coordinate.location)
                    .tint(pin.id == draft.addedStopID ? AppTheme.accent : pin.stop.place.category.color)
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .accessibilityLabel(TripText.planningMap.resource)
    }
}

#if DEBUG
#Preview("Visit map · system basemap, local places") {
    TripPlanningMapView(draft: TripPlanningPreview.fixture().1).frame(height: 260)
}
#Preview("Insertion map · dark") {
    TripPlanningMapView(draft: TripPlanningPreview.fixture(inserting: true).1)
        .frame(height: 260).preferredColorScheme(.dark)
}
#endif
