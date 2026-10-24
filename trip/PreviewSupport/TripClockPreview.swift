#if DEBUG
import Foundation
import TripDomain

enum TripClockPreview {
    static func draft(gap: Bool = false) -> TripEventDraft {
        var trip = TripJourneyPreview.plan()
        let date = TripLocalDate(year: 2026, month: gap ? 3 : 11, day: gap ? 8 : 1)
        _ = trip.reviewTimeZone("America/New_York", departure: date)
        var event = trip.events[0]
        event.departureTime = TripZonedDateTime(date: date, minute: gap ? 150 : 90, zoneID: "America/New_York")
        event.arrivalTime = nil
        event.endMinute = nil
        return TripEventDraft(trip: trip, dayID: trip.days[0].id, event: event)
    }
}
#endif
