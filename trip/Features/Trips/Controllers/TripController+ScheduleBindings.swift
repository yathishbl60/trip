import Foundation
import SwiftUI
import TripDomain

extension TripController {
    func reviewSchedule(day: TripDay, trip: TripPlan) {
        if trip.needsTimeZoneReview { model.beginEdit(trip.id) }
        else { model.beginDaySchedule(dayID: day.id, tripID: trip.id) }
    }

    func scheduleEnabled(_ draft: TripDayScheduleDraft) -> Binding<Bool> {
        Binding(get: { draft.enabled }, set: { draft.enabled = $0 })
    }

    func scheduleStart(_ draft: TripDayScheduleDraft) -> Binding<Date> {
        Binding(get: { draft.start }, set: { draft.setStart($0) })
    }

    func scheduleEnd(_ draft: TripDayScheduleDraft) -> Binding<Date> {
        Binding(get: { draft.end }, set: { draft.setEnd($0) })
    }

    func scheduleOccurrence(_ draft: TripDayScheduleDraft, end: Bool) -> Binding<TripClockOccurrence> {
        Binding(get: { end ? draft.endOccurrence : draft.startOccurrence }, set: {
            if end { draft.endOccurrence = $0 } else { draft.startOccurrence = $0 }
        })
    }

    func fixedArrival(_ draft: TripStopTimingDraft) -> Binding<Bool> {
        Binding(get: { draft.fixesArrival }, set: { draft.fixesArrival = $0 })
    }

    func arrival(_ draft: TripStopTimingDraft) -> Binding<Date> {
        Binding(get: { draft.arrival }, set: { draft.setArrival($0) })
    }

    func arrivalOccurrence(_ draft: TripStopTimingDraft) -> Binding<TripClockOccurrence> {
        Binding(get: { draft.timing.arrivalOccurrence }, set: { draft.timing.arrivalOccurrence = $0 })
    }

    func timingMinutes(_ keyPath: WritableKeyPath<TripStopTiming, Int>,
                       draft: TripStopTimingDraft) -> Binding<Int> {
        Binding(get: { draft.timing[keyPath: keyPath] }, set: { draft.setMinutes($0, for: keyPath) })
    }

    func timingSlider(_ keyPath: WritableKeyPath<TripStopTiming, Int>,
                      draft: TripStopTimingDraft) -> Binding<Double> {
        Binding(get: { Double(draft.timing[keyPath: keyPath]) }, set: { value in
            guard value.isFinite else { return }
            draft.setMinutes(Int(value.rounded()), for: keyPath)
        })
    }
}
