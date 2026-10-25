#if os(iOS)
import ActivityKit
import TripDomain
import TripStorage
import Foundation

extension TripJourneyRuntime {
    func begin(plan: TripSurfacePlan, day: TripSurfaceDay) async throws {
        let current = try await TripSystemData.store.journey()
        var next = resumableJourney(current, plan: plan, day: day)
        next.isActive = true
        next.reconcile(with: day)
        guard next.isActive else { throw TripSurfaceError.finishedDay }
        if hasActivity(next) {
            try await TripSystemData.store.saveJourney(next)
            journey = next
            try await updateActivities()
            return
        }
        let activityID = try request(plan: plan, day: day, journey: next).id
        try await persist(next, activityID: activityID)
        self.day = day
        for old in Activity<TripActivityAttributes>.activities where old.id != activityID {
            await old.end(nil, dismissalPolicy: .immediate)
        }
    }

    private func persist(_ next: TripJourney, activityID: String) async throws {
        do { try await TripSystemData.store.saveJourney(next) }
        catch {
            await Self.discardActivity(id: activityID)
            throw error
        }
        journey = next
    }

    @concurrent
    private nonisolated static func discardActivity(id: String) async {
        for activity in Activity<TripActivityAttributes>.activities where activity.id == id {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    func restoreAfterUndo() async throws {
        guard let journey, journey.isActive, !hasActivity(journey),
              let plan = try await TripSystemData.store.plan(journey.tripID),
              let day = plan.days.first(where: { $0.id == journey.dayID }) else {
            try await updateActivities()
            return
        }
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { throw TripJourneyError.disabled }
        try await begin(plan: plan, day: day)
    }

    private func resumableJourney(_ current: TripJourney?, plan: TripSurfacePlan, day: TripSurfaceDay) -> TripJourney {
        if let current, current.tripID == plan.id, current.dayID == day.id, current.expiresAt > .now {
            return current
        }
        return TripJourney(tripID: plan.id, dayID: day.id)
    }

    private func request(plan: TripSurfacePlan, day: TripSurfaceDay, journey: TripJourney) throws
        -> Activity<TripActivityAttributes> {
        let attributes = TripActivityAttributes(tripID: plan.id, dayID: day.id,
                                                tripTitle: plan.title, dayNumber: day.number)
        let state = TripActivityAttributes.ContentState(journey: journey, day: day, title: plan.title)
        return try Activity.request(attributes: attributes,
            content: ActivityContent(state: state, staleDate: journey.expiresAt), pushType: nil)
    }
}
#endif
