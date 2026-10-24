#if DEBUG
import Foundation
import TripDomain

/// Each preview owns its snapshots; no SwiftData container or app group is opened.
actor PreviewTripStore: TripStoring {
    private var plans: [TripPlan]
    private var revision = -1

    init(_ plans: [TripPlan]) { self.plans = plans }

    func load() -> [TripPlan] { plans }

    func save(_ plans: [TripPlan], revision: Int, changedIDs: Set<UUID>?) {
        guard revision > self.revision else { return }
        self.plans = plans
        self.revision = revision
    }
}
#endif
