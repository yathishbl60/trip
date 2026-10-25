#if os(visionOS)
import TripDomain
import TripStorage
import Foundation

extension TripJourneyRuntime {
    func begin(plan: TripSurfacePlan, day: TripSurfaceDay) async throws {
        let stored = try await TripSystemData.store.journey()
        var next = resumableJourney(stored, plan: plan, day: day)
        next.isActive = true
        next.reconcile(with: day)
        guard next.isActive else { throw TripSurfaceError.finishedDay }
        try await TripSystemData.store.saveJourney(next)
        journey = next
        self.day = day
    }

    func refresh() async {
        guard !isBusy else { needsRefresh = true; return }
        isBusy = true
        defer { finish() }
        do {
            journey = try await TripSystemData.store.journey()
            try await updateActivities()
        } catch { /* Retain the last available projection while shared data is protected. */ }
    }

    func updateActivities() async throws {
        guard var current = journey, let plan = try await TripSystemData.store.plan(current.tripID),
              let currentDay = plan.days.first(where: { $0.id == current.dayID }) else {
            journey = nil
            day = nil
            return
        }
        current.reconcile(with: currentDay)
        try await TripSystemData.store.saveJourney(current)
        journey = current
        day = currentDay
    }

    func restoreAfterUndo() async throws { try await updateActivities() }

    private func resumableJourney(_ stored: TripJourney?, plan: TripSurfacePlan, day: TripSurfaceDay) -> TripJourney {
        if let stored, stored.tripID == plan.id, stored.dayID == day.id, stored.expiresAt > .now { return stored }
        return TripJourney(tripID: plan.id, dayID: day.id)
    }
}
#endif
