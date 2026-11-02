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
        return await TripWidgetReader.entry(tripID: configuration.trip?.id, at: .now)
    }

    func timeline(for configuration: TripWidgetConfiguration, in context: Context) async -> Timeline<TripWidgetEntry> {
        let now = Date.now
        let current = await TripWidgetReader.entry(tripID: configuration.trip?.id, at: now)
        let calendar = current.plan?.days.first?.calendar ?? .current
        let midnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
            ?? now.addingTimeInterval(24 * 60 * 60)
        let next = await TripWidgetReader.entry(tripID: configuration.trip?.id, at: midnight)
        return Timeline(entries: [current, next], policy: .after(midnight))
    }
}
