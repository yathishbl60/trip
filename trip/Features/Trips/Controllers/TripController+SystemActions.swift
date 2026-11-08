import Foundation
import SwiftUI
import TripDomain

extension TripController {
    var supportsSystemExports: Bool { model.systemActions.service.supportsCalendarReminders }
    var supportsTravelAlarms: Bool { model.systemActions.service.supportsAlarms }

    func beginCalendarExport(tripID: UUID) {
        guard !model.hasEditingSession else { return }
        model.systemActions.showCalendar(tripID: tripID)
    }

    func beginRemindersExport(tripID: UUID) {
        guard !model.hasEditingSession else { return }
        model.systemActions.showReminders(tripID: tripID)
    }

    func beginAlarm(_ draft: TripEventDraft) {
        guard draft.original != nil, !draft.hasChanges else { return }
        model.systemActions.showAlarm(tripID: draft.tripID, eventID: draft.event.id)
    }

    func systemActionPresentation(bookingEditor: Bool) -> Binding<TripSystemActionSession?> {
        let sessionID = model.systemActions.presentation?.id
        return Binding(get: {
            guard let session = model.systemActions.presentation else { return nil }
            let belongsToEditor = session.kind == .alarm && model.presentation.eventDraft != nil
            guard belongsToEditor == bookingEditor else { return nil }
            return session
        }, set: { value in
            guard value == nil, let session = model.systemActions.presentation, session.id == sessionID else { return }
            let belongsToEditor = session.kind == .alarm && model.presentation.eventDraft != nil
            if belongsToEditor == bookingEditor { model.systemActions.dismiss() }
        })
    }
}
