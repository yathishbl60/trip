import Foundation
import TripDomain
#if os(iOS) || os(macOS)
import EventKit
#endif
#if os(iOS)
import AlarmKit
import AppIntents
#endif

/// Retain one instance at the app composition root; permission prompts never run from initialization.
@MainActor public final class AppleTripSystemActions: TripSystemActionProviding {
    private let defaults: UserDefaults
    lazy var ledger = TripActionLedger(defaults: defaults)
    var isSchedulingAlarm = false
    #if os(iOS) || os(macOS)
    lazy var eventStore = EKEventStore()
    #endif
    #if os(iOS)
    public var openAlarm: (@MainActor (TripSystemBooking) -> any LiveActivityIntent)?
    #endif

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var supportsCalendarReminders: Bool {
        #if os(iOS) || os(macOS)
        true
        #else
        false
        #endif
    }

    public var supportsAlarms: Bool {
        #if os(iOS)
        true
        #else
        false
        #endif
    }

    public func alarmDate(for booking: TripSystemBooking) -> Date? {
        #if os(iOS)
        guard let record = ledger.value.alarms[booking.id] else { return nil }
        guard !isSchedulingAlarm else { return record.date }
        if let alarms = try? AlarmManager.shared.alarms, !alarms.contains(where: { $0.id == record.id }) {
            ledger.value.alarms.removeValue(forKey: booking.id)
            ledger.save()
            return nil
        }
        return record.date
        #else
        return nil
        #endif
    }
}
