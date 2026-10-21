import Foundation
import TripDomain
#if os(iOS)
import AlarmKit
#endif

extension AppleTripSystemActions {
    public func authorizeAlarms() async throws {
        #if os(iOS)
        guard try await AlarmManager.shared.requestAuthorization() == .authorized else {
            throw TripSystemActionError.alarmsDenied
        }
        try Task.checkCancellation()
        #else
        throw TripSystemActionError.unavailable
        #endif
    }

    public func scheduleAlarm(for booking: TripSystemBooking, at date: Date) async throws -> UUID {
        #if os(iOS)
        guard !isSchedulingAlarm else { throw TripSystemActionError.busy }
        guard date.timeIntervalSinceReferenceDate.isFinite, date > .now else { throw TripSystemActionError.invalidTime }
        isSchedulingAlarm = true
        defer { isSchedulingAlarm = false }
        try Task.checkCancellation()
        try cancelAlarm(for: booking)
        let record = TripActionLedger.AlarmRecord(id: UUID(), booking: booking, date: date)
        ledger.value.alarms[booking.id] = record
        ledger.save()
        try await installAlarm(record)
        return record.id
        #else
        throw TripSystemActionError.unavailable
        #endif
    }

    public func cancelAlarm(for booking: TripSystemBooking, matching alarmID: UUID) throws {
        guard ledger.value.alarms[booking.id]?.id == alarmID else { return }
        try cancelAlarm(for: booking)
    }

    public func cancelAlarm(for booking: TripSystemBooking) throws {
        #if os(iOS)
        guard let record = ledger.value.alarms[booking.id] else { return }
        if try AlarmManager.shared.alarms.contains(where: { $0.id == record.id }) {
            try AlarmManager.shared.cancel(id: record.id)
        }
        ledger.value.alarms.removeValue(forKey: booking.id)
        ledger.save()
        #else
        throw TripSystemActionError.unavailable
        #endif
    }

    public func reconcileAlarms(with plans: [TripPlan]) async throws {
        #if os(iOS)
        guard !ledger.value.alarms.isEmpty else { return }
        let bookings = plans.flatMap { trip in trip.events.compactMap { TripSystemBooking(event: $0, trip: trip) } }
        let current = Dictionary(bookings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        try reconcileRecords(current)
        #endif
    }

    private func reconcileRecords(_ current: [String: TripSystemBooking]) throws {
        var failure: (any Error)?
        for record in Array(ledger.value.alarms.values) {
            if current[record.booking.id] != record.booking {
                do { try cancelAlarm(for: record.booking) }
                catch { failure = failure ?? error }
            } else {
                _ = alarmDate(for: record.booking)
            }
        }
        if let failure { throw failure }
    }
}
