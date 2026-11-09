import Foundation
import TripDomain
import TripLocalization
import WidgetKit

nonisolated enum TripWidgetTimeline {
    static func make(tripID: UUID?, purpose: TripSurfacePurpose, now: Date = .now) async -> Timeline<TripWidgetEntry> {
        do {
            var reader = try await TripWidgetReader()
            return await entries(reader: &reader, tripID: tripID, purpose: purpose, now: now)
        } catch {
            let entry = TripWidgetEntry(date: now, notice: TripText.openTripToRefreshYourItinerary.text)
            return Timeline(entries: [entry], policy: .after(now.addingTimeInterval(15 * 60)))
        }
    }

    private static func entries(reader: inout TripWidgetReader, tripID: UUID?, purpose: TripSurfacePurpose,
                                now: Date) async -> Timeline<TripWidgetEntry> {
        let horizon = now.addingTimeInterval(24 * 60 * 60)
        var date = now
        var entries: [TripWidgetEntry] = []
        for _ in 0..<32 {
            var entry = await reader.entry(tripID: tripID, at: date, purpose: purpose)
            if reader.needsRetry, !entries.isEmpty { break }
            entry.relevance = purpose == .departure ? TripWidgetRelevance.preparation(entry) : TripWidgetRelevance.itinerary(entry)
            entries.append(entry)
            guard date < horizon, !Task.isCancelled, !reader.needsRetry else { break }
            date = nextDate(entry, purpose: purpose, index: reader.index, horizon: horizon)
        }
        let reload = reader.needsRetry ? now.addingTimeInterval(15 * 60) : entries.last?.date ?? horizon
        return Timeline(entries: entries, policy: .after(reload))
    }

    private static func nextDate(_ entry: TripWidgetEntry, purpose: TripSurfacePurpose,
                                  index: TripSurfaceIndex?, horizon: Date) -> Date {
        var candidates = [index?.nextMidnight(after: entry.date), horizon].compactMap { $0 }
        if purpose == .itinerary {
            candidates += [entry.day.flatMap { TripSurfaceAgenda.nextChange(in: $0, after: entry.date) }?.addingTimeInterval(1),
                           entry.journey?.expiresAt, TripWidgetRelevance.nextChange(entry)].compactMap { $0 }
        }
        let boundary = candidates.filter { $0 > entry.date }.min() ?? horizon
        let next = max(boundary, entry.date.addingTimeInterval(5 * 60))
        return horizon.timeIntervalSince(next) < 5 * 60 ? horizon : next
    }
}
