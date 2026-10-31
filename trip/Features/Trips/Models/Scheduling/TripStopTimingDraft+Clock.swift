import Foundation
import TripDomain

extension TripStopTimingDraft {
    var utc: Calendar { TripLocalDate.calendar(zoneID: "Etc/UTC") }
    var pickerBase: Date {
        TripLocalDate(date, calendar: calendar).noon(in: utc) ?? date
    }
    var arrivalClock: TripZonedDateTime? { value.arrivalClock(on: date, calendar: calendar) }

    static func initialArrival(trip: TripPlan, day: TripDay, stop: TripStop) -> Date {
        let date = trip.date(for: day)
        if let clock = stop.timing.arrivalClock(on: date, calendar: trip.calendar) { return clock.pickerDate }
        let planned = TripDayTimeline(day: day, date: date, calendar: trip.calendar)?[stop.id]?.arrival ?? date
        return TripZonedDateTime(date: TripLocalDate(planned, calendar: trip.calendar),
                                 minute: TripScheduleClock.minute(of: planned, calendar: trip.calendar),
                                 zoneID: trip.calendar.timeZone.identifier).pickerDate
    }

    func setArrival(_ date: Date) {
        arrival = date
        timing.arrivalOccurrence = .unresolved
    }
}
