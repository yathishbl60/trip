import Foundation
import TripDomain
import WidgetKit

/// Local saved dates inform Smart Rotate; WidgetKit decides actual placement.
nonisolated enum TripWidgetRelevance {
    private static let upcomingWindow: TimeInterval = 60 * 60

    static func itinerary(_ entry: TripWidgetEntry) -> TimelineEntryRelevance? {
        let validity = entry.isTracking ? (entry.journey?.expiresAt.timeIntervalSince(entry.date) ?? 0) : .infinity
        if let boundary = upcomingBoundary(entry) {
            let duration = boundary.timeIntervalSince(entry.date)
            if duration <= upcomingWindow { return TimelineEntryRelevance(score: 90, duration: min(duration, validity)) }
        }
        guard entry.isTracking, entry.item != nil else { return nil }
        return TimelineEntryRelevance(score: 60, duration: validity)
    }

    static func nextChange(_ entry: TripWidgetEntry) -> Date? {
        guard let boundary = upcomingBoundary(entry) else { return nil }
        let start = boundary.addingTimeInterval(-upcomingWindow)
        return start > entry.date ? start : nil
    }

    static func preparation(_ entry: TripWidgetEntry) -> TimelineEntryRelevance? {
        let presentation = TripReadinessPresentation(entry: entry)
        guard let remaining = presentation.progress?.remaining, remaining > 0,
              let days = presentation.daysUntilDeparture, (0...1).contains(days),
              let calendar = entry.plan?.days.first?.calendar,
              let midnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: entry.date)) else { return nil }
        return TimelineEntryRelevance(score: days == 0 ? 70 : 40, duration: midnight.timeIntervalSince(entry.date))
    }

    private static func upcomingBoundary(_ entry: TripWidgetEntry) -> Date? {
        guard let item = entry.item, item.requiresTimeReview != true else { return nil }
        return [item.startsAt, item.endsAt].compactMap { $0 }.filter { $0 > entry.date }.min()
    }
}
