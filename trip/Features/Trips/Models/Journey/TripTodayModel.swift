import TripLocalization
import Foundation
import TripDomain

struct TripTodayModel {
    let snapshot: TripTodaySnapshot
    let now: Date
    var next: TripTodayItem? { snapshot.next }
    var rest: [TripTodayItem] { snapshot.items.filter { $0.id != next?.id } }
    var isAvailable: Bool { snapshot.day != nil || snapshot.needsTimeZoneReview }
    var showsEntry: Bool { snapshot.needsTimeZoneReview || (snapshot.day != nil && !snapshot.items.isEmpty) }
    var subtitle: String {
        if snapshot.needsTimeZoneReview { return TripText.confirmYourDestinationTimeZone.text }
        return next?.title ?? (snapshot.day == nil ? TripText.noItineraryDayToday.text : TripText.youReAllCaughtUp.text)
    }
    var emptyTitle: String {
        snapshot.day == nil ? TripText.noItineraryDayToday.text : (snapshot.items.isEmpty ? TripText.aDayToMakeYourOwn.text : TripText.nothingElseComingUp.text)
    }
    var emptyMessage: String {
        snapshot.day == nil ? TripText.todayFollowsYourSavedTripTimeZoneYourFull.text
            : TripText.openTheItineraryToAddPlansOrRevisitYour.text
    }
    var zoneText: String { TripText.timesInValue(snapshot.calendar.timeZone.identifier).text }

    func timeText(_ item: TripTodayItem) -> String {
        if item.requiresTimeReview { return TripText.reviewSavedTime.text }
        guard let time = item.startsAt else { return TripText.flexibleTime.text }
        let calendar = TripLocalDate.calendar(zoneID: item.zoneID)
        let value = TripScheduleText.time(time, relativeTo: now, calendar: calendar)
        return "\(item.isEstimate ? "Estimated " : "")\(value) · \(item.zoneID)"
    }

    func leaveText(_ item: TripTodayItem) -> String? {
        guard let leave = item.leaveBy, !item.requiresTimeReview, let start = item.startsAt, start > now else { return nil }
        let calendar = TripLocalDate.calendar(zoneID: item.zoneID)
        let time = TripScheduleText.time(leave, relativeTo: now, calendar: calendar)
        return leave > now ? TripText.leaveByValue(time).text : TripText.yourManualLeaveByTimeHasPassedValue(time).text
    }

    func statusText(_ item: TripTodayItem) -> String {
        if item.isVisited { return TripText.visited.text }
        if !item.requiresTimeReview, let time = item.startsAt, time < now {
            return TripText.scheduledEarlierValue(timeText(item)).text
        }
        return timeText(item)
    }
}
