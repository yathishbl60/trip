#if os(iOS)
import AlarmKit
import AppIntents
import Foundation
import SwiftUI
import TripDomain
import TripLocalization

extension AppleTripSystemActions {
    func installAlarm(_ record: TripActionLedger.AlarmRecord) async throws {
        do {
            try Task.checkCancellation()
            let configuration = alarmConfiguration(record)
            _ = try await AlarmManager.shared.schedule(id: record.id, configuration: configuration)
        } catch {
            forgetFailedScheduleIfAbsent(record)
            throw error
        }
        if Task.isCancelled || ledger.value.alarms[record.booking.id]?.id != record.id {
            try cancelSupersededAlarm(record)
            throw CancellationError()
        }
    }

    private func forgetFailedScheduleIfAbsent(_ record: TripActionLedger.AlarmRecord) {
        guard let alarms = try? AlarmManager.shared.alarms,
              !alarms.contains(where: { $0.id == record.id }),
              ledger.value.alarms[record.booking.id]?.id == record.id else { return }
        ledger.value.alarms.removeValue(forKey: record.booking.id)
        ledger.save()
    }

    private func cancelSupersededAlarm(_ record: TripActionLedger.AlarmRecord) throws {
        // A schedule may finish after reconciliation cancelled its still-pending record.
        ledger.value.alarms[record.booking.id] = record
        ledger.save()
        try cancelAlarm(for: record.booking)
    }

    private func alarmConfiguration(_ record: TripActionLedger.AlarmRecord) -> sending AlarmManager.AlarmConfiguration<BookingAlarmMetadata> {
        let open = openAlarm?(record.booking)
        let button = AlarmButton(text: TripText.openTrip.resource, textColor: .white, systemImageName: "suitcase.rolling")
        let alert = AlarmPresentation.Alert(title: LocalizedStringResource("\(record.booking.title)"),
                                            secondaryButton: open == nil ? nil : button,
                                            secondaryButtonBehavior: open == nil ? nil : .custom)
        let metadata = BookingAlarmMetadata(tripID: record.booking.tripID, eventID: record.booking.eventID)
        let attributes = AlarmAttributes(presentation: AlarmPresentation(alert: alert), metadata: metadata, tintColor: .blue)
        return .alarm(schedule: .fixed(record.date), attributes: attributes, secondaryIntent: open)
    }
}

private nonisolated struct BookingAlarmMetadata: AlarmMetadata {
    let tripID: UUID
    let eventID: UUID
}
#endif
