#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated struct TripDayBriefing: Sendable {
    public let plan: TripSurfacePlan
    public let date: Date
    public let day: TripSurfaceDay?
    public var items: [TripSurfaceItem] { day?.agenda ?? [] }

    public init(plan: TripSurfacePlan, date: Date) {
        self.plan = plan
        self.date = date
        day = plan.days.first { $0.calendar.isDate($0.date, inSameDayAs: date) }
    }

    public var heading: String {
        let zone = day?.calendar.timeZone ?? plan.days.first?.calendar.timeZone ?? .current
        let date = date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, timeZone: zone))
        return day.map { TripText.dayValueValue(TripText.number($0.number), date).text } ?? date
    }
    public var text: String {
        guard let day else { return TripText.valueNoItineraryPlannedForValue(plan.title, heading).text }
        return "\(plan.title). \(TripSurfaceAgenda.description(day))"
    }
    public var spokenSummary: String {
        guard !items.isEmpty else { return TripText.valueValueNothingPlannedYet(plan.title, heading).text }
        let details = items.prefix(3).map { "\($0.title), \($0.timeText)" }.joined(separator: "; ")
        let remaining = items.count > 3 ? TripText.plusValueMoreItemsOpenTripForTheFull(TripText.number(items.count - 3)).text : ""
        return ["\(plan.title), \(heading). \(details).", remaining].filter { !$0.isEmpty }.joined(separator: " ")
    }
}
