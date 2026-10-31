import Foundation
import TripDomain

struct TripJourneyDayModel {
    let items: [TripJourneyItem]
    let timeline: TripDayTimeline?
    private let visitNumbers: [UUID: Int]

    init(trip: TripPlan, day: TripDay) {
        items = trip.journeyItems(on: day)
        timeline = trip.needsTimeZoneReview ? nil : TripDayTimeline(day: day, date: trip.date(for: day), calendar: trip.calendar)
        visitNumbers = Dictionary(day.stops.enumerated().map { ($0.element.id, $0.offset + 1) },
                                  uniquingKeysWith: { first, _ in first })
    }

    func number(for stop: TripStop) -> Int { visitNumbers[stop.id] ?? 1 }
    func continues(after item: TripJourneyItem) -> Bool { item.id != items.last?.id }
}
