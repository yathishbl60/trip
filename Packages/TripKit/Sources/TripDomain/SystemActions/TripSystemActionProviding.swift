import Foundation

/// Authorization is separate so the host can revalidate canonical data after a system prompt.
@MainActor public protocol TripSystemActionProviding: AnyObject {
    var supportsCalendarReminders: Bool { get }
    var supportsAlarms: Bool { get }
    func authorizeCalendar() async throws
    func exportCalendar(_ bookings: [TripSystemBooking]) throws -> Int
    func authorizeReminders() async throws
    func exportReminders(_ items: [TripReminderExport], due: Date?) throws -> Int
    func authorizeAlarms() async throws
    func scheduleAlarm(for booking: TripSystemBooking, at date: Date) async throws -> UUID
    func cancelAlarm(for booking: TripSystemBooking) throws
    func cancelAlarm(for booking: TripSystemBooking, matching alarmID: UUID) throws
    func alarmDate(for booking: TripSystemBooking) -> Date?
    func reconcileAlarms(with plans: [TripPlan]) async throws
}
