import TripLocalization
import Foundation
import SwiftUI
import TripDomain

extension TripController {
    func today(_ tripID: UUID, at now: Date) -> TripTodayModel? { model.today(tripID, at: now) }
    func openTodayItem(_ item: TripTodayItem, tripID: UUID, directions: Bool = false) {
        model.openTodayItem(item, tripID: tripID, directions: directions)
    }

    func todayActionTitle(_ item: TripTodayItem) -> String {
        if item.requiresTimeReview { return TripText.reviewTime.text }
        if item.item.stop != nil { return model.environment.showDirections == nil ? TripText.showOnMap.text : TripText.directions.text }
        return TripText.openEventDetails.text
    }

    func eventAllowanceEnabled(_ draft: TripEventDraft) -> Binding<Bool> {
        Binding(get: { draft.event.travelAllowanceMinutes != nil },
                set: { draft.set($0 ? 30 : nil, at: \.travelAllowanceMinutes) })
    }

    func eventAllowance(_ draft: TripEventDraft) -> Binding<Int> {
        Binding(get: { draft.event.travelAllowanceMinutes ?? 30 },
                set: { draft.set(min(1440, max(0, $0)), at: \.travelAllowanceMinutes) })
    }
}
