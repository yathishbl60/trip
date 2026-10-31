import TripLocalization
import TripDomain

extension TripPlan {
    var pendingChecklistItems: [TripChecklistItem] { checklist.filter { !$0.isComplete } }
    var completedChecklistItems: [TripChecklistItem] { checklist.filter(\.isComplete) }
    var completedChecklistCount: Int { checklist.count(where: \.isComplete) }
    var checklistSummary: String {
        checklist.isEmpty ? TripText.packingPreparation.text : TripText.valueOfValueDone(TripText.number(completedChecklistCount), TripText.number(checklist.count)).text
    }
    var canAddChecklistItem: Bool { checklist.count < TripLimits.checklistItems }
}
