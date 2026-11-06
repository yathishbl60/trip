import Foundation
import Observation
import Synchronization

@MainActor final class ProjectionLifecycleChecks {
    private let model = LayoutModel()
    private var delivered: [Int] = []
    private var didRefine = false

    func run() async throws {
        defer { model.stop() }
        try await invalidationCancelsWork()
        try await restart()
        try await gestureCancelsSettledWork()
        try await suspensionCancelsWork()
        try await ProjectionReadinessChecks.run()
        try await MapOcclusionChecks.run()
        print("PASS: projection invalidation notifies observers, cancels queued work, and permits a fresh layout")
    }

    private func invalidationCancelsWork() async throws {
        let updates = ObservationCounter()
        withObservationTracking {
            _ = model.projectionRevision
        } onChange: {
            updates.count.withLock { $0 += 1 }
        }
        enqueue()
        let refinement = startRefinement()
        model.invalidateProjection()
        await refinement.value
        try require(refinement.isCancelled && !didRefine, "Invalidated projection continued refinement")
        try require(delivered.isEmpty, "Invalidated layout published stale coordinates")
        try require(model.generation == 1 && model.projectionRevision == 1, "Projection generation did not advance")
        try require(updates.count.withLock { $0 } == 1, "MapReader was not notified to capture fresh coordinates")
    }

    private func restart() async throws {
        enqueue()
        let deadline = ContinuousClock.now.advanced(by: .seconds(5))
        while delivered.isEmpty && .now < deadline { try await Task.sleep(for: .milliseconds(1)) }
        try require(delivered == [model.generation], "Restart published an invalidated layout or never completed")
    }

    private func suspensionCancelsWork() async throws {
        delivered.removeAll()
        enqueue()
        let refinement = startRefinement()
        let generation = model.generation
        model.stop()
        await refinement.value
        try require(refinement.isCancelled && !didRefine, "Suspended map continued refinement")
        try require(delivered.isEmpty && model.generation > generation, "Suspended map retained publishable work")
    }

    private func gestureCancelsSettledWork() async throws {
        delivered.removeAll()
        enqueue()
        let refinement = startRefinement()
        let revision = model.projectionRevision
        let generation = model.generation
        model.cancelPending()
        await refinement.value
        try require(refinement.isCancelled && delivered.isEmpty, "A new gesture published the previous settled layout")
        try require(model.generation > generation, "A new gesture kept the old layout generation")
        try require(model.projectionRevision == revision, "Gesture cancellation invalidated the map view")
        try await restart()
    }

    private func enqueue() {
        let request = CheckFixtures.request(CheckFixtures.candidates(0), zoom: .street, frame: model.generation)
        model.scheduler.submit(request) { [self] request, _ in delivered.append(request.generation) }
    }

    private func startRefinement() -> Task<Void, Never> {
        let task = Task {
            do {
                try await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                didRefine = true
            } catch { /* Cancellation must prevent the delayed callback. */ }
        }
        model.refinementTask = task
        return task
    }
}
