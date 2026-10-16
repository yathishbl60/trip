#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated struct TripChecklistBriefing: Sendable {
    public let title: String
    public let progress: TripChecklistProgress
    public let pending: [TripChecklistItem]

    public init(_ plan: TripPlan) {
        title = String(plan.title.prefix(TripLimits.titleCharacters))
        progress = TripChecklistProgress(plan)
        pending = plan.checklist.prefix(TripLimits.checklistItems).filter { !$0.isComplete }
    }

    public var summary: String {
        if progress.total == 0 { return TripText.yourChecklistIsEmptyAddItemsOrTravelEssentials.text }
        if pending.isEmpty { return TripText.allValueChecklistItemsAreDone(TripText.number(progress.total)).text }
        return TripText.valueOfValueDoneValueItemsLeft(TripText.number(progress.completed), TripText.number(progress.total), TripText.number(pending.count)).text
    }

    public var text: String { ([title, summary] + pending.map { "• \($0.title)" }).joined(separator: "\n") }
    public var spokenSummary: String {
        guard !pending.isEmpty else { return "\(title). \(summary)" }
        let next = pending.prefix(3).map { String($0.title.prefix(TripLimits.titleCharacters)) }.formatted()
        return TripText.valueValueNextValue(title, summary, next).text
    }
}
