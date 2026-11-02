import SwiftUI
import WidgetKit

struct TripReadinessWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: TripSystemData.readinessWidgetKind, intent: TripWidgetConfiguration.self,
                               provider: TripReadinessProvider()) { entry in
            TripReadinessView(presentation: TripReadinessPresentation(entry: entry))
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(TripReadinessPresentation(entry: entry).url)
                .privacySensitive()
        }
        .configurationDisplayName("departure_checklist")
        .description("count_down_to_departure_and_see_packing_progress_tap")
        .supportedFamilies(Self.families)
        #if os(visionOS)
        .supportedMountingStyles([.elevated, .recessed])
        .widgetTexture(.glass)
        #endif
    }

    private static var families: [WidgetFamily] {
        #if os(iOS)
        [.systemSmall, .systemMedium, .accessoryRectangular]
        #else
        [.systemSmall, .systemMedium]
        #endif
    }
}

#if DEBUG
#Preview("Packing progress · small", as: .systemSmall) {
    TripReadinessWidget()
} timeline: { TripWidgetFixtures.packing }
#Preview("Packing progress · medium", as: .systemMedium) {
    TripReadinessWidget()
} timeline: { TripWidgetFixtures.packing }
#Preview("Packing complete · small", as: .systemSmall) {
    TripReadinessWidget()
} timeline: { TripWidgetFixtures.packed }
#if os(iOS)
#Preview("Packing · Lock Screen", as: .accessoryRectangular) {
    TripReadinessWidget()
} timeline: { TripWidgetFixtures.packing }
#endif
#endif
