import Foundation
import Observation
import TripDomain

@MainActor @Observable final class TripSystemActionSession: Identifiable {
    enum Kind { case calendar, reminders, alarm }
    let id = UUID()
    let kind: Kind
    let tripID: UUID
    var bookings: [TripSystemBooking] = []
    var reminders: [TripReminderExport] = []
    var booking: TripSystemBooking?
    var selectedIDs: Set<String> = []
    var usesDueDate = false
    var dueDate = Date.now
    var alarmDate = Date.now
    var scheduledAlarmDate: Date?
    var error: String?
    var recovery: String?
    var result: String?

    init(kind: Kind, tripID: UUID) {
        self.kind = kind
        self.tripID = tripID
    }
}
