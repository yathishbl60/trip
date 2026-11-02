import TripLocalization
import WidgetKit
import TripDomain
import Foundation

nonisolated struct TripWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> TripWidgetEntry {
        let date = Date(timeIntervalSince1970: 1_791_331_200)
        let stop = TripSurfaceStop(id: UUID(uuidString: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE")!,
            name: TripText.morningMuseumVisit.text, category: .museum, coordinate: Coordinate(latitude: 0, longitude: 0))
        let day = TripSurfaceDay(id: UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!,
                                 number: 1, date: date, stops: [stop])
        let plan = TripSurfacePlan(id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!,
                                   title: TripText.sampleTrip.text, startDate: date, days: [day])
        return TripWidgetEntry(date: date, plan: plan, day: day)
    }

    func snapshot(for configuration: TripWidgetConfiguration, in context: Context) async -> TripWidgetEntry {
        if context.isPreview { return placeholder(in: context) }
        return await TripWidgetReader.entry(tripID: configuration.trip?.id, at: .now)
    }

    func timeline(for configuration: TripWidgetConfiguration, in context: Context) async -> Timeline<TripWidgetEntry> {
        let now = Date.now
        let current = await TripWidgetReader.entry(tripID: configuration.trip?.id, at: now)
        let calendar = current.day?.calendar ?? .current
        let midnight = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
            ?? now.addingTimeInterval(24 * 60 * 60)
        let change = current.day.flatMap { TripSurfaceAgenda.nextChange(in: $0, after: now) }
        let expiry = current.journey?.expiresAt
        let pendingExpiry = expiry.flatMap { $0 > now ? $0 : nil }
        let boundary = min(midnight, pendingExpiry ?? midnight,
                           change?.addingTimeInterval(1) ?? midnight)
        let later = await TripWidgetReader.entry(tripID: configuration.trip?.id, at: max(boundary, now.addingTimeInterval(60)))
        return Timeline(entries: [current, later], policy: .after(later.date))
    }
}
