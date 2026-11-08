import TripDomain
import Foundation

@MainActor final class AppSystemModel {
    private var generation = 0
    private var publicationTask: Task<Void, Never>?
    private var activePublication: Task<Void, Never>?
    private var pendingPublication: (plans: [TripPlan], token: Int)?
    private(set) var publicationRevision = 0
    private var refreshRevision = 0
    private let spotlight = TripSpotlightModel()
    private let systemActions: any TripSystemActionProviding
    private let journey: TripJourneyRuntime
    var error: String?

    init(systemActions: any TripSystemActionProviding, journey: TripJourneyRuntime) {
        self.systemActions = systemActions
        self.journey = journey
    }

    func publish(_ plans: [TripPlan]) async {
        // Durable publication outlives the save caller; only newer snapshots cancel active work.
        generation += 1
        pendingPublication = (plans, generation)
        activePublication?.cancel()
        if let publicationTask { await publicationTask.value; return }
        let task = Task { await drainPublications() }
        publicationTask = task
        await task.value
    }

    private func drainPublications() async {
        defer {
            publicationTask = nil
            activePublication = nil
        }
        while let pending = pendingPublication {
            pendingPublication = nil
            let task = Task { await performPublication(pending.plans, token: pending.token) }
            activePublication = task
            await task.value
        }
    }

    private func performPublication(_ plans: [TripPlan], token: Int) async {
        do {
            let snapshots = try await AppSystemProjection.snapshots(plans)
            guard !Task.isCancelled, token == generation else { return }
            let alarmError = await reconcileAlarms(plans)
            guard !Task.isCancelled, token == generation else { return }
            try await publishSurfaces(snapshots, token: token, alarmError: alarmError)
        } catch is CancellationError {
            return
        } catch {
            if token == generation { self.error = error.localizedDescription }
        }
    }

    private func publishSurfaces(_ snapshots: [TripSurfacePlan], token: Int, alarmError: String?) async throws {
        try await TripSystemData.publish(snapshots, at: .now)
        guard !Task.isCancelled, token == generation else { return }
        reloadSurfaces()
        await spotlight.publish(snapshots)
        guard !Task.isCancelled, token == generation else { return }
        await journey.refresh()
        guard !Task.isCancelled, token == generation else { return }
        error = alarmError
        publicationRevision = token
    }

    func refresh(_ plans: [TripPlan], since publication: Int? = nil) async {
        guard !Task.isCancelled, publicationTask == nil,
              publication == nil || publication == publicationRevision else { return }
        refreshRevision += 1
        let revision = refreshRevision
        let publicationGeneration = generation
        let alarmError = await reconcileAlarms(plans)
        guard !Task.isCancelled, revision == refreshRevision, publicationGeneration == generation else { return }
        if let alarmError { error = alarmError }
        await journey.refresh()
    }

    private func reconcileAlarms(_ plans: [TripPlan]) async -> String? {
        do { try await systemActions.reconcileAlarms(with: plans); return nil }
        catch { return error.localizedDescription }
    }

}
