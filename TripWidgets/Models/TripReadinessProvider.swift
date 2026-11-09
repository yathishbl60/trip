import Foundation
import WidgetKit
import TripDomain

nonisolated struct TripReadinessProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TripWidgetEntry {
        var entry = TripWidgetProvider().placeholder(in: context)
        entry.plan?.checklistProgress = TripChecklistProgress(total: 8, completed: 5)
        return entry
    }

    func snapshot(for configuration: TripWidgetConfiguration, in context: Context) async -> TripWidgetEntry {
        if context.isPreview { return placeholder(in: context) }
        return await TripWidgetReader.entry(tripID: configuration.trip?.id, at: .now, purpose: .departure)
    }

    func timeline(for configuration: TripWidgetConfiguration, in context: Context) async -> Timeline<TripWidgetEntry> {
        await TripWidgetTimeline.make(tripID: configuration.trip?.id, purpose: .departure)
    }
}
