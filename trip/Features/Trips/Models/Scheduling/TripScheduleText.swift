import TripLocalization
import Foundation
import TripDomain

nonisolated enum TripScheduleText {
    static func duration(_ minutes: Int) -> String {
        Duration.seconds(Double(minutes) * 60).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }

    static func time(_ date: Date, relativeTo day: Date, calendar: Calendar = .current) -> String {
        let style = Date.FormatStyle(date: calendar.isDate(date, inSameDayAs: day) ? .omitted : .abbreviated,
                                     time: .shortened, timeZone: calendar.timeZone)
        return date.formatted(style)
    }

    static func range(from start: Date, to end: Date, relativeTo day: Date? = nil, calendar: Calendar = .current) -> String {
        "\(time(start, relativeTo: day ?? start, calendar: calendar)) – \(time(end, relativeTo: start, calendar: calendar))"
    }
}

extension TripDayTimeline {
    var summaryText: String {
        entries.isEmpty ? TripText.startsValue(TripScheduleText.time(start, relativeTo: start, calendar: calendar)).text
            : TripScheduleText.range(from: start, to: end, calendar: calendar)
    }

    var targetText: String { TripText.targetFinishValue(TripScheduleText.time(targetEnd, relativeTo: start, calendar: calendar)).text }

    var sharingText: String {
        ([summaryText, targetText, TripText.travelTimesAreManualAllowances.text] + warnings).joined(separator: "\n")
    }

    var warnings: [String] {
        var warnings = entries.compactMap(\.arrivalIssue)
        if overrunMinutes > 0 {
            warnings.append(TripText.valuePastYourTarget(TripScheduleText.duration(overrunMinutes)).text)
        }
        if conflictCount > 0 {
            warnings.append(TripText.arrivalConflictCount(conflictCount).text)
        }
        return warnings
    }
}

extension TripTimelineEntry {
    var calendar: Calendar { TripLocalDate.calendar(zoneID: timeZoneID ?? TimeZone.current.identifier) }
    var timeText: String {
        arrivalIssue == nil ? TripScheduleText.range(from: arrival, to: departure, relativeTo: day, calendar: calendar)
            : TripText.reviewArrivalTime.text
    }
    var visitText: String { TripText.valueVisit(TripScheduleText.duration(visitMinutes)).text }

    var sharingText: String {
        [timeText, visitText, allowanceText, waitingText, conflictText, arrivalIssue].compactMap { $0 }.joined(separator: " · ")
    }

    var allowanceText: String? {
        guard travelMinutes + bufferMinutes > 0 else { return nil }
        return TripText.valueTravelValueBuffer(TripScheduleText.duration(travelMinutes), TripScheduleText.duration(bufferMinutes)).text
    }

    var waitingText: String? {
        waitingMinutes > 0 ? TripText.valueFreeBeforeThisVisit(TripScheduleText.duration(waitingMinutes)).text : nil
    }

    var conflictText: String? {
        guard lateMinutes > 0, let fixedArrival else { return nil }
        let requested = TripScheduleText.time(fixedArrival, relativeTo: arrival, calendar: calendar)
        return TripText.valueLateFixedArrivalValue(TripScheduleText.duration(lateMinutes), requested).text
    }
}
