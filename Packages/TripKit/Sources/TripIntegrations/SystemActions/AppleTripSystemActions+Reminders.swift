import Foundation
import TripDomain
#if os(iOS) || os(macOS)
import EventKit
#endif

extension AppleTripSystemActions {
    public func authorizeReminders() async throws {
        #if os(iOS) || os(macOS)
        guard try await eventStore.requestFullAccessToReminders() else { throw TripSystemActionError.remindersDenied }
        try Task.checkCancellation()
        #else
        throw TripSystemActionError.unavailable
        #endif
    }

    public func exportReminders(_ items: [TripReminderExport], due: Date?) throws -> Int {
        #if os(iOS) || os(macOS)
        let pending = pendingReminderExports(items)
        guard !pending.isEmpty else { return 0 }
        guard let calendar = eventStore.defaultCalendarForNewReminders() else { throw TripSystemActionError.missingCalendar }
        for item in pending {
            try Task.checkCancellation()
            try eventStore.save(reminder(item, calendar: calendar, due: due), commit: true)
            ledger.value.reminderExports.insert(item.id)
            ledger.save()
        }
        return pending.count
        #else
        throw TripSystemActionError.unavailable
        #endif
    }

    private func pendingReminderExports(_ items: [TripReminderExport]) -> [TripReminderExport] {
        var seen: Set<String> = []
        return items.filter { seen.insert($0.id).inserted && !ledger.value.reminderExports.contains($0.id) }
    }

    #if os(iOS) || os(macOS)
    private func reminder(_ item: TripReminderExport, calendar: EKCalendar, due: Date?) -> EKReminder {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.calendar = calendar
        reminder.title = item.title
        reminder.url = item.deepLink
        if let due {
            var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: due)
            components.timeZone = .current
            reminder.dueDateComponents = components
            reminder.addAlarm(EKAlarm(absoluteDate: due))
        }
        return reminder
    }
    #endif
}
