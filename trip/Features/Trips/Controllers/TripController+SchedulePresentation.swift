import Foundation
import SwiftUI

extension TripController {
    var daySchedule: Binding<TripDayScheduleDraft?> {
        let id = model.presentation.daySchedule?.id
        return Binding(get: { model.presentation.daySchedule }, set: { value in
            guard value == nil, model.presentation.daySchedule?.id == id else { return }
            model.presentation.daySchedule = nil
        })
    }

    var stopTiming: Binding<TripStopTimingDraft?> {
        let id = model.presentation.stopTiming?.id
        return Binding(get: { model.presentation.stopTiming }, set: { value in
            guard value == nil, model.presentation.stopTiming?.id == id else { return }
            model.presentation.stopTiming = nil
        })
    }

    func beginDaySchedule(dayID: UUID, tripID: UUID) { model.beginDaySchedule(dayID: dayID, tripID: tripID) }
    func beginStopTiming(stopID: UUID, dayID: UUID, tripID: UUID) {
        model.beginStopTiming(stopID: stopID, dayID: dayID, tripID: tripID)
    }
    func saveDaySchedule(_ draft: TripDayScheduleDraft) { model.saveDaySchedule(draft) }
    func saveStopTiming(_ draft: TripStopTimingDraft) { model.saveStopTiming(draft) }

    func cancelDaySchedule(_ draft: TripDayScheduleDraft) {
        guard model.presentation.daySchedule?.id == draft.id else { return }
        model.presentation.daySchedule = nil
    }

    func cancelStopTiming(_ draft: TripStopTimingDraft) {
        guard model.presentation.stopTiming?.id == draft.id else { return }
        model.presentation.stopTiming = nil
    }
}
