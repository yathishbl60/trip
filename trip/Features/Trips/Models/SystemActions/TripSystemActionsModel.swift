import Foundation
import Observation
import TripDomain
import TripLocalization

@MainActor @Observable final class TripSystemActionsModel {
    var presentation: TripSystemActionSession?
    private(set) var isWorking = false
    let service: any TripSystemActionProviding
    let library: TripLibraryModel
    @ObservationIgnored var task: Task<Void, Never>?

    init(service: any TripSystemActionProviding, library: TripLibraryModel) {
        self.service = service
        self.library = library
    }

    func showCalendar(tripID: UUID) {
        guard let trip = library.trip(tripID) else { return }
        let session = TripSystemActionSession(kind: .calendar, tripID: tripID)
        session.bookings = trip.events.compactMap { TripSystemBooking(event: $0, trip: trip) }.filter(\.canExportCalendar)
        session.selectedIDs = Set(session.bookings.map(\.id))
        show(session)
    }

    func showReminders(tripID: UUID) {
        guard let trip = library.trip(tripID) else { return }
        let session = TripSystemActionSession(kind: .reminders, tripID: tripID)
        session.reminders = trip.checklist.filter { !$0.isComplete }.map { TripReminderExport(tripID: tripID, item: $0) }
        session.selectedIDs = Set(session.reminders.map(\.id))
        session.dueDate = max(trip.startDate, .now)
        show(session)
    }

    func showAlarm(tripID: UUID, eventID: UUID) {
        guard let trip = library.trip(tripID), let event = trip.events.first(where: { $0.id == eventID }) else { return }
        let session = TripSystemActionSession(kind: .alarm, tripID: tripID)
        session.booking = TripSystemBooking(event: event, trip: trip)
        session.scheduledAlarmDate = session.booking.flatMap { service.alarmDate(for: $0) }
        if let booking = session.booking, let suggestion = booking.suggestedAlarmDate, suggestion > .now {
            session.alarmDate = max(session.scheduledAlarmDate ?? suggestion, .now)
        } else { session.error = TripText.reviewSystemActionTime.text }
        show(session)
    }

    private func show(_ session: TripSystemActionSession) {
        dismiss()
        presentation = session
    }

    func dismiss() {
        task?.cancel()
        task = nil
        presentation = nil
        isWorking = false
    }

    func perform() {
        guard let session = presentation, !isWorking, canPerform else { return }
        session.error = nil
        session.recovery = nil
        session.result = nil
        isWorking = true
        task = Task { [weak self] in await self?.run(session) }
    }

    func finish(_ session: TripSystemActionSession) {
        guard presentation?.id == session.id else { return }
        isWorking = false
        task = nil
    }
}
