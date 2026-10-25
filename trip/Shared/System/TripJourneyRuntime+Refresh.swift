#if os(iOS)
import ActivityKit
import TripDomain
import TripStorage
import Foundation

extension TripJourneyRuntime {
    func refresh() async {
        guard !isBusy else { needsRefresh = true; return }
        isBusy = true
        defer { finish() }
        do {
            try await reconcileJourney()
            try await updateActivities()
        } catch { /* Keep the last known state when protected shared data is unavailable. */ }
    }

    private func reconcileJourney() async throws {
        let stored = try await TripSystemData.store.journey()
        guard var current = stored, let plan = try await TripSystemData.store.plan(current.tripID),
              let day = plan.days.first(where: { $0.id == current.dayID }) else {
            journey = nil
            day = nil
            return
        }
        current.reconcile(with: day)
        if !hasActivity(current) { current.isActive = false }
        try await TripSystemData.store.saveJourney(current)
        self.day = day
        journey = current
    }

    func updateActivities() async throws {
        var plan: TripSurfacePlan?
        if let journey { plan = try await TripSystemData.store.plan(journey.tripID) }
        day = plan?.days.first { $0.id == journey?.dayID }
        for activity in Activity<TripActivityAttributes>.activities {
            guard let journey, let day,
                  activity.attributes.tripID == journey.tripID, activity.attributes.dayID == journey.dayID else {
                await activity.end(nil, dismissalPolicy: .immediate)
                continue
            }
            self.day = day
            let state = TripActivityAttributes.ContentState(journey: journey, day: day, title: plan?.title)
            let content = ActivityContent(state: state, staleDate: journey.expiresAt)
            if journey.isActive { await activity.update(content) }
            else { await activity.end(content, dismissalPolicy: .default) }
        }
    }

    func hasActivity(_ journey: TripJourney) -> Bool {
        Activity<TripActivityAttributes>.activities.contains {
            $0.attributes.tripID == journey.tripID && $0.attributes.dayID == journey.dayID && $0.activityState == .active
        }
    }
}
#endif
