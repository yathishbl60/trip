import Foundation
import TripDomain
#if os(iOS) || os(macOS)
import EventKit
#endif

extension AppleTripSystemActions {
    public func authorizeCalendar() async throws {
        #if os(iOS) || os(macOS)
        guard try await eventStore.requestWriteOnlyAccessToEvents() else { throw TripSystemActionError.calendarDenied }
        try Task.checkCancellation()
        #else
        throw TripSystemActionError.unavailable
        #endif
    }

    public func exportCalendar(_ bookings: [TripSystemBooking]) throws -> Int {
        #if os(iOS) || os(macOS)
        let pending = pendingCalendarExports(bookings)
        guard !pending.isEmpty else { return 0 }
        guard pending.allSatisfy(\.canExportCalendar) else { throw TripSystemActionError.invalidTime }
        guard let calendar = eventStore.defaultCalendarForNewEvents else { throw TripSystemActionError.missingCalendar }
        for booking in pending {
            try Task.checkCancellation()
            try eventStore.save(calendarEvent(booking, calendar: calendar), span: .thisEvent, commit: true)
            ledger.value.calendarExports.insert(booking.id)
            ledger.save()
        }
        return pending.count
        #else
        throw TripSystemActionError.unavailable
        #endif
    }

    private func pendingCalendarExports(_ bookings: [TripSystemBooking]) -> [TripSystemBooking] {
        var seen: Set<String> = []
        return bookings.filter { seen.insert($0.id).inserted && !ledger.value.calendarExports.contains($0.id) }
    }

    #if os(iOS) || os(macOS)
    private func calendarEvent(_ booking: TripSystemBooking, calendar: EKCalendar) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = booking.title
        event.location = booking.location
        event.startDate = booking.start
        event.endDate = booking.end
        event.timeZone = booking.timeZone
        event.url = booking.deepLink
        return event
    }
    #endif
}
