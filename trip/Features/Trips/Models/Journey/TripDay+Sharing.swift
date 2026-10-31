import TripLocalization
import Foundation
import TripDomain

extension TripDay {
    func shareText(in trip: TripPlan) -> String {
        let date = trip.dateText(for: self)
        let timeline = trip.needsTimeZoneReview ? nil : TripDayTimeline(day: self, date: trip.date(for: self), calendar: trip.calendar)
        let items = trip.journeyItems(on: self).map { item in
            item.sharingText(day: self, trip: trip, timeline: timeline, includesAddress: true)
        }.joined(separator: "\n\n")
        let header = ["\(trip.title)\n\(title) · \(date)", journeyScheduleText(timeline, trip: trip)]
            .compactMap { $0 }.joined(separator: "\n")
        return "\(header)\n\n\(items)"
    }

    func sharedSummary(in trip: TripPlan) -> String {
        let timeline = trip.needsTimeZoneReview ? nil : TripDayTimeline(day: self, date: trip.date(for: self), calendar: trip.calendar)
        let items = trip.journeyItems(on: self).map { item in
            item.sharingText(day: self, trip: trip, timeline: timeline, includesAddress: false)
        }
        return ([title, notes, journeyScheduleText(timeline, trip: trip) ?? ""] + items)
            .filter { !$0.isEmpty }.joined(separator: "\n")
    }

    private func journeyScheduleText(_ timeline: TripDayTimeline?, trip: TripPlan) -> String? {
        if let issue = scheduleIssue(in: trip) { return TripText.scheduleNeedsReviewValue(issue).text }
        guard let timeline else { return nil }
        guard !trip.events.isEmpty else { return timeline.sharingText }
        return TripText.placeScheduleExcludesEventsNValue(timeline.sharingText).text
    }
}
