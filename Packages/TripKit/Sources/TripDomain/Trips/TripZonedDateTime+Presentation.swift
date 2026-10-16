#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

extension TripZonedDateTime {
    public nonisolated var description: String {
        guard let instant else { return TripText.valueValueValueValueValueReviewTime(String(date.year), TripText.number(date.month), TripText.number(date.day), clockText, zoneID).text }
        return "\(instant.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: calendar.timeZone))) · \(zoneID)"
    }
    public nonisolated var clockText: String { String(format: "%02d:%02d", minute / 60, minute % 60) }
    public nonisolated func occurrenceLabel(_ occurrence: TripClockOccurrence) -> String {
        let label = occurrence == .first ? TripText.first.text : TripText.second.text
        guard let instant = occurrence == .first ? candidates.first : candidates.last else { return label }
        let offset = calendar.timeZone.secondsFromGMT(for: instant)
        let hours = abs(offset) / 3600
        let minutes = abs(offset) / 60 % 60
        return "\(label) · UTC\(offset < 0 ? "−" : "+")\(String(format: "%02d:%02d", hours, minutes))"
    }
    public nonisolated var pickerDate: Date {
        let utc = TripLocalDate.calendar(zoneID: "Etc/UTC")
        return utc.date(from: DateComponents(year: date.year, month: date.month, day: date.day,
                                             hour: minute / 60, minute: minute % 60)) ?? .distantPast
    }

    public nonisolated mutating func setPickerDate(_ value: Date) {
        let utc = TripLocalDate.calendar(zoneID: "Etc/UTC")
        date = TripLocalDate(value, calendar: utc)
        minute = TripScheduleClock.minute(of: value, calendar: utc)
        occurrence = .unresolved
    }
}
