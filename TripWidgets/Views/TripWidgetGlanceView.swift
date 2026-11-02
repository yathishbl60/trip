#if os(visionOS)
import SwiftUI
import WidgetKit

struct TripWidgetGlanceView: View {
    let entry: TripWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(entry.title, systemImage: "suitcase.rolling")
                .font(.headline).foregroundStyle(.secondary).lineLimit(1)
            Text(entry.stopTitle).font(.title2.bold()).lineLimit(2)
            Text(entry.isTracking ? entry.progress : entry.detail).font(.headline)
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Spatial widget · glance at a distance", as: .systemSmall) {
    TripItineraryWidget()
} timeline: { TripWidgetFixtures.active }
#endif
#endif
