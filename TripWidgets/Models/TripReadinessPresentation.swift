import TripLocalization
import Foundation
import TripDomain

nonisolated struct TripReadinessPresentation {
    let entry: TripWidgetEntry
    var progress: TripChecklistProgress? { entry.plan?.checklistProgress }
    var url: URL? { entry.plan.flatMap { TripSystemData.checklistURL($0.id) } ?? TripSystemData.tripsURL }
    var departure: Date? { entry.plan?.startDate }
    var departureText: String {
        guard let plan = entry.plan else { return entry.notice }
        let zone = plan.days.first?.calendar.timeZone ?? .current
        return plan.startDate.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, timeZone: zone))
    }
    var daysUntilDeparture: Int? {
        guard let plan = entry.plan else { return nil }
        let calendar = plan.days.first?.calendar ?? .current
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: entry.date),
                                       to: calendar.startOfDay(for: plan.startDate)).day
    }
    var status: String {
        guard entry.plan != nil else { return TripText.openTripToGetStarted.text }
        guard let progress else { return TripText.openTripToRefreshYourChecklist.text }
        if progress.total == 0 { return TripText.addYourPackingChecklist.text }
        if progress.remaining == 0 { return TripText.checklistComplete.text }
        return TripText.valueChecklistItemsLeft(progress.remaining).text
    }
    var summary: String {
        guard let progress, progress.total > 0 else { return status }
        return TripText.valueOfValueDone(TripText.number(progress.completed), TripText.number(progress.total)).text
    }
    var countdown: String {
        guard let days = daysUntilDeparture else { return TripText.yourNextTrip.text }
        if days > 1 { return TripText.departsInValueDays(days).text }
        if days == 1 { return TripText.departsTomorrow.text }
        if days == 0 { return TripText.departureDay.text }
        return TripText.departedValue(departureText).text
    }
}
