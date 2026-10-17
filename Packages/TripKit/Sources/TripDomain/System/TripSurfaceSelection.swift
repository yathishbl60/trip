import Foundation

/// Retains visits for the displayed day without letting ended tracking pin an old day.
public nonisolated struct TripSurfaceSelection: Sendable {
    public let day: TripSurfaceDay?
    public let journey: TripJourney?

    public init(plan: TripSurfacePlan, journey: TripJourney?, at date: Date) {
        let current = Self.reconciled(journey, in: plan, at: date)
        let tracked = current?.isActive == true ? plan.days.first { $0.id == current?.dayID } : nil
        let selected = tracked ?? plan.day(at: date)
        day = selected
        self.journey = current?.dayID == selected?.id ? current : nil
    }

    private static func reconciled(_ journey: TripJourney?, in plan: TripSurfacePlan, at date: Date) -> TripJourney? {
        guard var journey, journey.tripID == plan.id,
              let day = plan.days.first(where: { $0.id == journey.dayID }) else { return nil }
        journey.reconcile(with: day, now: date)
        return journey
    }
}
