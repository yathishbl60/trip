import TripLocalization
import Foundation
import TripDomain

extension TripModel {
    func beginDaySchedule(dayID: UUID, tripID: UUID) {
        guard let trip = library.trip(tripID), let day = trip.days.first(where: { $0.id == dayID }) else { return }
        guard !trip.needsTimeZoneReview else { presentation.notice = TripText.confirmThisTripSTimeZoneInEditTrip.text; return }
        presentation.daySchedule = TripDayScheduleDraft(trip: trip, day: day)
    }

    func beginStopTiming(stopID: UUID, dayID: UUID, tripID: UUID) {
        guard let trip = library.trip(tripID), let day = trip.days.first(where: { $0.id == dayID }),
              let stop = day.stops.first(where: { $0.id == stopID }) else { return }
        guard !trip.needsTimeZoneReview else { presentation.notice = TripText.confirmThisTripSTimeZoneInEditTrip.text; return }
        presentation.stopTiming = TripStopTimingDraft(trip: trip, day: day, stop: stop)
    }

    func saveDaySchedule(_ draft: TripDayScheduleDraft) {
        guard presentation.daySchedule?.id == draft.id else { return }
        if draft.isUnchanged {
            presentation.daySchedule = nil
            return
        }
        guard let trip = library.trip(draft.tripID) else {
            draft.error = TripText.thisTripIsNoLongerAvailable.text
            return
        }
        let saved = library.updateDay(draft.dayID, in: draft.tripID) { day in
            let date = trip.date(for: day)
            return draft.apply(to: &day, on: date, calendar: trip.calendar)
        }
        if saved { presentation.daySchedule = nil }
        else if draft.error == nil { draft.error = TripText.thisDayIsNoLongerAvailable.text }
    }

    func saveStopTiming(_ draft: TripStopTimingDraft) {
        guard presentation.stopTiming?.id == draft.id else { return }
        if draft.isUnchanged {
            presentation.stopTiming = nil
            return
        }
        guard let trip = library.trip(draft.tripID) else {
            draft.error = TripText.thisTripIsNoLongerAvailable.text
            return
        }
        let saved = library.updateDay(draft.dayID, in: draft.tripID) { day in
            guard let index = day.stops.firstIndex(where: { $0.id == draft.stopID }) else { return false }
            let date = trip.date(for: day)
            return draft.apply(to: &day.stops[index], on: date, calendar: trip.calendar)
        }
        if saved { presentation.stopTiming = nil }
        else if draft.error == nil { draft.error = TripText.thisPlaceIsNoLongerInThisDay.text }
    }

    func timeline(for day: TripDay, in trip: TripPlan) -> TripDayTimeline? {
        guard !trip.needsTimeZoneReview else { return nil }
        return TripDayTimeline(day: day, date: trip.date(for: day), calendar: trip.calendar)
    }
}
