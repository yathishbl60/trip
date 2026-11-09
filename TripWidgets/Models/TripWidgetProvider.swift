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
        await TripWidgetTimeline.make(tripID: configuration.trip?.id, purpose: .itinerary)
    }
}
