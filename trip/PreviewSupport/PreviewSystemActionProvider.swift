#if DEBUG
import Foundation
import TripDomain

@MainActor final class PreviewSystemActionProvider: TripSystemActionProviding {
    let supportsCalendarReminders = true
    let supportsAlarms = true
    private var alarms: [String: (id: UUID, date: Date)] = [:]
    private var calendarIDs: Set<String> = []
    private var reminderIDs: Set<String> = []

    func authorizeCalendar() async throws {}
    func authorizeReminders() async throws {}
    func authorizeAlarms() async throws {}

    func exportCalendar(_ bookings: [TripSystemBooking]) throws -> Int {
        bookings.reduce(0) { $0 + (calendarIDs.insert($1.id).inserted ? 1 : 0) }
    }

    func exportReminders(_ items: [TripReminderExport], due: Date?) throws -> Int {
        items.reduce(0) { $0 + (reminderIDs.insert($1.id).inserted ? 1 : 0) }
    }

    func scheduleAlarm(for booking: TripSystemBooking, at date: Date) async throws -> UUID {
        let id = UUID()
        alarms[booking.id] = (id, date)
        return id
    }
    func cancelAlarm(for booking: TripSystemBooking) throws { alarms.removeValue(forKey: booking.id) }
    func cancelAlarm(for booking: TripSystemBooking, matching alarmID: UUID) throws {
        if alarms[booking.id]?.id == alarmID { alarms.removeValue(forKey: booking.id) }
    }
    func alarmDate(for booking: TripSystemBooking) -> Date? { alarms[booking.id]?.date }
    func reconcileAlarms(with plans: [TripPlan]) async throws {}
}
#endif
