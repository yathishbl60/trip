import AppIntents
import WidgetKit

struct TripWidgetConfiguration: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "choose_atrip2" }
    static var description: IntentDescription {
        IntentDescription("choose_asaved_trip_or_leave_empty_to_follow")
    }
    @Parameter(title: "trip") var trip: SavedTripEntity?

    static var families: [WidgetFamily] {
        #if os(iOS)
        [.systemSmall, .systemMedium, .accessoryInline, .accessoryRectangular, .accessoryCircular]
        #else
        [.systemSmall, .systemMedium]
        #endif
    }
}
