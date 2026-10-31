import TripLocalization
import Foundation
import Observation
import TripDomain

@MainActor @Observable final class TripStopTimingDraft: Identifiable, TripDiscardableDraft {
    let id = UUID()
    let tripID: UUID
    let dayID: UUID
    let stopID: UUID
    let title: String
    let date: Date
    let calendar: Calendar
    let isFirst: Bool
    private let original: TripStopTiming
    var timing: TripStopTiming
    var fixesArrival: Bool
    var arrival: Date
    var error: String?
    var isDiscarding = false

    init(trip: TripPlan, day: TripDay, stop: TripStop) {
        tripID = trip.id
        dayID = day.id
        stopID = stop.id
        title = stop.place.name
        date = trip.date(for: day)
        calendar = trip.calendar
        isFirst = day.stops.first?.id == stop.id
        original = stop.timing
        timing = stop.timing.normalized
        fixesArrival = stop.timing.arrivalMinute != nil
        arrival = Self.initialArrival(trip: trip, day: day, stop: stop)
    }

    var value: TripStopTiming {
        var value = timing.normalized
        value.arrivalMinute = fixesArrival ? TripScheduleClock.offset(of: arrival, from: pickerBase, calendar: utc) : nil
        return value
    }

    var isUnchanged: Bool { value == original }
    var hasUnsavedChanges: Bool { value != original.normalized }
    var arrivalRange: ClosedRange<Date> {
        utc.startOfDay(for: pickerBase)...TripScheduleClock.date(minute: 2879, on: pickerBase, calendar: utc)
    }

    func setMinutes(_ value: Int, for keyPath: WritableKeyPath<TripStopTiming, Int>) {
        timing[keyPath: keyPath] = value
        timing = timing.normalized
    }

    func apply(to stop: inout TripStop, on currentDate: Date, calendar current: Calendar) -> Bool {
        if fixesArrival, let issue = arrivalClock?.issue { error = issue; return false }
        guard calendar.timeZone == current.timeZone, calendar.isDate(date, inSameDayAs: currentDate) else {
            error = TripText.thisDaySDateOrTimeZoneChangedClose2.text
            return false
        }
        guard stop.timing == original || stop.timing == value else {
            error = TripText.theseVisitTimesChangedElsewhereCloseAndReopenTo.text
            return false
        }
        stop.timing = value
        return true
    }

    func preview(in trip: TripPlan?) -> TripTimelineEntry? {
        guard let trip, var day = trip.days.first(where: { $0.id == dayID }),
              let index = day.stops.firstIndex(where: { $0.id == stopID }) else { return nil }
        day.stops[index].timing = value
        return TripDayTimeline(day: day, date: trip.date(for: day), calendar: trip.calendar)?[stopID]
    }
}
