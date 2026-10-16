import Foundation

/// Planned time only. Travel and buffer values are the user's allowances, not route estimates.
public nonisolated struct TripTimeBudget: Sendable {
    public let visits: Int
    public let travel: Int
    public let betweenVisits: Int
    public let open: Int
    public let target: Int
    public let overrun: Int

    public init(timeline: TripDayTimeline) {
        visits = timeline.entries.reduce(0) { $0 + $1.visitMinutes }
        travel = timeline.entries.reduce(0) { $0 + $1.travelMinutes }
        betweenVisits = timeline.entries.reduce(0) { $0 + $1.bufferMinutes + $1.waitingMinutes }
        target = max(0, Int(timeline.targetEnd.timeIntervalSince(timeline.start) / 60))
        let planned = visits + travel + betweenVisits
        open = max(0, target - planned)
        overrun = max(0, planned - target)
    }

    public var total: Int { visits + travel + betweenVisits + open }
}
