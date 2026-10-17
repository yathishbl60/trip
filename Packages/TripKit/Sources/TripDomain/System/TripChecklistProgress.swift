import Foundation

/// Counts only: checklist text never enters widget projections or Spotlight.
public nonisolated struct TripChecklistProgress: Codable, Equatable, Sendable {
    public let total: Int
    public let completed: Int
    public var remaining: Int { max(0, total - completed) }

    public init(total: Int, completed: Int) {
        self.total = min(TripLimits.checklistItems, max(0, total))
        self.completed = min(self.total, max(0, completed))
    }

    public init(_ plan: TripPlan) {
        let items = plan.checklist.prefix(TripLimits.checklistItems)
        self.init(total: items.count, completed: items.count(where: \.isComplete))
    }
}
