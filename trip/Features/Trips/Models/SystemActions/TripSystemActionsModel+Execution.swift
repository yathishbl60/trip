import Foundation
import TripDomain
import TripLocalization

extension TripSystemActionsModel {
    func run(_ session: TripSystemActionSession) async {
        defer { finish(session) }
        do {
            await library.flush()
            guard library.saveError == nil else { throw TripTrackingError.saveFailed }
            try Task.checkCancellation()
            switch session.kind {
            case .calendar: try await exportCalendar(session)
            case .reminders: try await exportReminders(session)
            case .alarm: try await scheduleAlarm(session)
            }
        } catch is CancellationError { return }
        catch { present(error, for: session) }
    }

    private func present(_ error: Error, for session: TripSystemActionSession) {
        guard presentation?.id == session.id else { return }
        session.error = error.localizedDescription
        if session.kind != .alarm { session.recovery = TripText.systemExportRecovery.text }
    }

    private func exportCalendar(_ session: TripSystemActionSession) async throws {
        let selected = session.bookings.filter { session.selectedIDs.contains($0.id) }
        try await service.authorizeCalendar()
        try validate(session)
        guard selected.allSatisfy(isCurrent) else { throw TripSystemActionError.changed }
        let count = try service.exportCalendar(selected)
        session.result = count == 0 ? TripText.calendarNothingNew.text : TripText.calendarExported.text
    }

    private func exportReminders(_ session: TripSystemActionSession) async throws {
        let selected = session.reminders.filter { session.selectedIDs.contains($0.id) }
        let due = session.usesDueDate ? session.dueDate : nil
        try await service.authorizeReminders()
        try validate(session)
        guard let trip = library.trip(session.tripID) else { throw TripSystemActionError.changed }
        let current = trip.checklist.filter { !$0.isComplete }.map { TripReminderExport(tripID: trip.id, item: $0) }
        guard selected.allSatisfy(current.contains) else { throw TripSystemActionError.changed }
        let count = try service.exportReminders(selected, due: due)
        session.result = count == 0 ? TripText.remindersNothingNew.text : TripText.remindersExported.text
    }

    private func scheduleAlarm(_ session: TripSystemActionSession) async throws {
        guard let booking = session.booking else { throw TripSystemActionError.invalidTime }
        let date = session.alarmDate
        try await service.authorizeAlarms()
        try validate(session)
        guard isCurrent(booking) else { throw TripSystemActionError.changed }
        let alarmID = try await service.scheduleAlarm(for: booking, at: date)
        if !isCurrent(booking) || Task.isCancelled {
            try service.cancelAlarm(for: booking, matching: alarmID)
            throw TripSystemActionError.changed
        }
        session.scheduledAlarmDate = service.alarmDate(for: booking)
        session.result = TripText.travelAlarmScheduled.text
    }

    private func validate(_ session: TripSystemActionSession) throws {
        try Task.checkCancellation()
        guard presentation?.id == session.id, library.trip(session.tripID) != nil else { throw TripSystemActionError.changed }
    }

    func isCurrent(_ booking: TripSystemBooking) -> Bool {
        guard let trip = library.trip(booking.tripID),
              let event = trip.events.first(where: { $0.id == booking.eventID }) else { return false }
        return TripSystemBooking(event: event, trip: trip) == booking
    }

    func cancelAlarm() {
        guard let session = presentation, let booking = session.booking, !isWorking else { return }
        do {
            try service.cancelAlarm(for: booking)
            session.scheduledAlarmDate = nil
            session.result = TripText.travelAlarmCancelled.text
            session.error = nil
        } catch { session.error = error.localizedDescription }
    }
}
