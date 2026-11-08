import Foundation
import TripDomain

/// Prepare immutable system data without occupying the UI actor.
nonisolated enum AppSystemProjection {
    @concurrent static func snapshots(_ plans: [TripPlan]) async throws -> [TripSurfacePlan] {
        try plans.map { plan in
            try Task.checkCancellation()
            return TripSurfacePlan(plan)
        }
    }

    @concurrent static func details(in plans: [TripSurfacePlan], now: Date) async throws -> [AppSpotlightDetail] {
        var details: [AppSpotlightDetail] = []
        for plan in plans.sorted(by: { $0.startDate < $1.startDate }) {
            try Task.checkCancellation()
            let days = plan.days.filter { $0.date >= $0.calendar.startOfDay(for: now) }
            let upcoming = TripSurfacePlan(id: plan.id, title: plan.title, startDate: plan.startDate, days: days)
            let results = TripDetailQuery().results(in: upcoming)
            for result in results.prefix(300 - details.count) {
                try Task.checkCancellation()
                details.append(AppSpotlightDetail(result: result, plan: upcoming))
            }
            if details.count >= 300 { break }
        }
        return details
    }
}

nonisolated struct AppSpotlightDetail: Sendable {
    let result: TripDetailResult
    let plan: TripSurfacePlan
}
