import SwiftUI
import TripLocalization

struct TripWidgetDirectionsLink: View {
    let entry: TripWidgetEntry

    var body: some View {
        if let url = entry.directionsURL {
            Link(destination: url) {
                Image(systemName: "arrow.triangle.turn.up.right.diamond").font(.headline)
            }
            .buttonStyle(.bordered).buttonBorderShape(.circle)
            .accessibilityLabel(TripText.directionsToValueInMaps(entry.stopTitle).resource)
        }
    }
}

#if DEBUG
#Preview("Widget directions · saved place") {
    TripWidgetDirectionsLink(entry: TripWidgetFixtures.active).padding()
}
#Preview("Widget directions · no saved coordinate") {
    TripWidgetDirectionsLink(entry: TripWidgetFixtures.flightAfterVisits).padding()
}
#endif
