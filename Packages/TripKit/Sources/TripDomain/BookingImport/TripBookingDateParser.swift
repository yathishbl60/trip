import Foundation

/// Deliberately excludes ambiguous numeric day/month ordering, missing years, and missing clocks.
nonisolated enum TripBookingDateParser {
    private static let dates: [(pattern: String, formats: [String])] = [
        (#"\d{4}-\d{2}-\d{2}"#, ["yyyy-MM-dd"]),
        (#"\d{1,2} [A-Za-z]{3,9} \d{4}"#, ["d MMM yyyy", "d MMMM yyyy"]),
        (#"[A-Za-z]{3,9} \d{1,2}, \d{4}"#, ["MMM d, yyyy", "MMMM d, yyyy"])
    ]
    private static let timePattern = #"\d{1,2}:\d{2}(?::\d{2})?(?:[ \t]*[APap][Mm])?"#
    private static let zonePattern = #"(?:[ \t]*(?:Z|[+-]\d{2}:?\d{2}|(?:UTC|GMT)(?:[+-]\d{1,2}(?::\d{2})?)?)\b)?"#

    static func candidates(in text: String) -> [TripBookingDateCandidate] {
        var candidates: [Int: TripBookingDateCandidate] = [:]
        for specification in dates {
            let pattern = #"\b("# + specification.pattern + "[ T]" + timePattern + ")" + zonePattern
                + #"(?![\w:]|[ \t]+[APap]\.?[Mm]\b)"#
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                guard let range = Range(match.range, in: text), let clockRange = Range(match.range(at: 1), in: text),
                      let candidate = parse(String(text[range]), clock: String(text[clockRange]), id: match.range.location,
                                            formats: specification.formats) else { continue }
                candidates[candidate.id] = candidate
            }
        }
        return Array(candidates.values.sorted { $0.id < $1.id }.prefix(TripBookingLimits.maximumDateCandidates))
    }

    private static func parse(_ source: String, clock: String, id: Int, formats: [String]) -> TripBookingDateCandidate? {
        let calendar = TripLocalDate.calendar(zoneID: "Etc/UTC")
        let normalized = clock.replacingOccurrences(of: #"(?<=\d)T(?=\d)"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"(?<=\d)(?=[APap][Mm]$)"#, with: " ", options: .regularExpression)
            .split(whereSeparator: \.isWhitespace).joined(separator: " ")
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.isLenient = false
        for format in formats {
            formatter.dateFormat = format + " " + clockFormat(normalized)
            guard let instant = formatter.date(from: normalized) else { continue }
            let date = TripLocalDate(instant, calendar: calendar)
            let minute = TripScheduleClock.minute(of: instant, calendar: calendar)
            return TripBookingDateCandidate(id: id, sourceText: source, date: date, minute: minute)
        }
        return nil
    }

    private static func clockFormat(_ clock: String) -> String {
        let meridiem = clock.range(of: #"[APap][Mm]$"#, options: .regularExpression) != nil
        let seconds = clock.range(of: #"\d:\d{2}:\d{2}"#, options: .regularExpression) != nil
        return (meridiem ? "h:mm" : "HH:mm") + (seconds ? ":ss" : "") + (meridiem ? " a" : "")
    }
}
