import Foundation
import TripDomain

@MainActor final class NavigationTestSystemActions: TripSystemActionProviding {
    let supportsCalendarReminders = false
    let supportsAlarms = false

    func authorizeCalendar() async throws { throw NavigationTestFailure.unexpectedService }
    func authorizeReminders() async throws { throw NavigationTestFailure.unexpectedService }
    func authorizeAlarms() async throws { throw NavigationTestFailure.unexpectedService }
    func exportCalendar(_ bookings: [TripSystemBooking]) throws -> Int { throw NavigationTestFailure.unexpectedService }
    func exportReminders(_ items: [TripReminderExport], due: Date?) throws -> Int { throw NavigationTestFailure.unexpectedService }
    func scheduleAlarm(for booking: TripSystemBooking, at date: Date) async throws -> UUID {
        throw NavigationTestFailure.unexpectedService
    }
    func cancelAlarm(for booking: TripSystemBooking) throws { throw NavigationTestFailure.unexpectedService }
    func cancelAlarm(for booking: TripSystemBooking, matching alarmID: UUID) throws { throw NavigationTestFailure.unexpectedService }
    func alarmDate(for booking: TripSystemBooking) -> Date? { nil }
    func reconcileAlarms(with plans: [TripPlan]) async throws { throw NavigationTestFailure.unexpectedService }
}
