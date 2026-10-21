import Foundation
import TripDomain

/// Write-only Calendar access cannot inspect earlier exports; remember them locally to prevent duplicates.
@MainActor final class TripActionLedger {
    private let defaults: UserDefaults
    private let key = "trip.system-actions.v1"
    var value: Value

    init(defaults: UserDefaults) {
        self.defaults = defaults
        value = defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(Value.self, from: $0) } ?? Value()
    }

    func save() {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    nonisolated struct Value: Codable {
        var calendarExports: Set<String> = []
        var reminderExports: Set<String> = []
        var alarms: [String: AlarmRecord] = [:]
    }

    nonisolated struct AlarmRecord: Codable {
        let id: UUID
        let booking: TripSystemBooking
        let date: Date
    }
}
