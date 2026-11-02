import SwiftUI
import WidgetKit

struct TripItineraryWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: TripSystemData.widgetKind, intent: TripWidgetConfiguration.self,
                               provider: TripWidgetProvider()) { entry in
            TripWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(entry.url)
                .privacySensitive()
        }
        .configurationDisplayName("next_on_your_trip")
        .description("see_upcoming_places_flights_stays_reservations_and_visited_progress")
        .supportedFamilies(TripWidgetConfiguration.families)
        #if os(visionOS)
        .supportedMountingStyles([.elevated, .recessed])
        .widgetTexture(.glass)
        #endif
    }
}

#if DEBUG
#Preview("Next place · sample", as: .systemSmall) {
    TripItineraryWidget()
} timeline: { TripWidgetFixtures.planned }
#Preview("Tracked day · sample", as: .systemMedium) {
    TripItineraryWidget()
} timeline: { TripWidgetFixtures.active }
#Preview("Flight · small", as: .systemSmall) {
    TripItineraryWidget()
} timeline: { TripWidgetFixtures.flight }
#Preview("Flight · medium", as: .systemMedium) {
    TripItineraryWidget()
} timeline: { TripWidgetFixtures.flight }
#endif
