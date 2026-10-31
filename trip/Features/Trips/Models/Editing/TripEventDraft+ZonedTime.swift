import TripLocalization
import Foundation
import TripDomain

extension TripEventDraft {
    func clock(arrival: Bool) -> TripZonedDateTime {
        let saved = arrival ? event.arrivalTime : event.departureTime
        let dayID = arrival ? event.endDayID : event.startDayID
        let minute = (arrival ? event.endMinute : event.startMinute) ?? 540
        return saved ?? event.legacyTime(minute, dayID: dayID, trip: sourceTrip)
            ?? TripZonedDateTime(date: TripLocalDate(originalDate, calendar: sourceTrip.calendar),
                                 minute: minute, zoneID: sourceTrip.calendar.timeZone.identifier)
    }

    func setClock(_ value: TripZonedDateTime?, arrival: Bool) {
        if arrival { event.arrivalTime = value; event.endMinute = value?.minute }
        else { event.departureTime = value; event.startMinute = value?.minute }
        error = nil
    }

    func setClockDate(_ date: Date, arrival: Bool) {
        var clock = clock(arrival: arrival)
        clock.setPickerDate(date)
        setClock(clock, arrival: arrival)
    }

    func setClockZone(_ zone: String, arrival: Bool) {
        var clock = clock(arrival: arrival)
        clock.zoneID = zone
        clock.occurrence = .unresolved
        setClock(clock, arrival: arrival)
    }

    func setClockOccurrence(_ value: TripClockOccurrence, arrival: Bool) {
        var clock = clock(arrival: arrival)
        clock.occurrence = value
        setClock(clock, arrival: arrival)
    }

    var elapsedText: String? {
        event.elapsedDuration.map { TripText.elapsedValue(TripScheduleText.duration(Int($0 / 60))).text }
    }
}
