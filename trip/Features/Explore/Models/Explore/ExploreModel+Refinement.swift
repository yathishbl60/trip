import MapEngine
import Foundation

extension ExploreModel {
    func scheduleRefinement(_ projection: MapProjection, generation: Int) {
        layout.refinementTask?.cancel()
        guard !camera.isMoving, layout.needsRefinement else { return }
        let delay = configuration.motion.refinement
        layout.refinementTask = Task { [weak self] in
            do {
                try await Task.sleep(for: delay)
                guard !Task.isCancelled else { return }
                self?.refine(projection, generation: generation)
            } catch { /* A new gesture or projection request supersedes refinement. */ }
        }
    }

    func refine(_ projection: MapProjection, generation: Int) {
        guard !isSuspended, !camera.isMoving, generation == layout.generation else { return }
        submitLayout(projection)
    }
}
