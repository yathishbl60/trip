#if !TRIP_STANDALONE
import MapEngine
#endif
import Foundation

/// One worker and one replaceable pending request bound work during fast gestures.
@MainActor final class LayoutScheduler {
    private let engine = MarkerLayoutEngine()
    private var task: Task<Void, Never>?
    private var pending: LayoutJob?
    private var epoch = 0
    private var latestGeneration = 0

    func submit(_ request: LayoutRequest, completion: @escaping LayoutJob.Completion) {
        latestGeneration = request.generation
        pending = LayoutJob(request: request, completion: completion)
        guard task == nil else { return }
        let epoch = epoch
        task = Task { await drain(epoch: epoch) }
    }

    private func drain(epoch: Int) async {
        defer { if epoch == self.epoch { task = nil } }
        while let job = pending, !Task.isCancelled, epoch == self.epoch {
            pending = nil
            do {
                let placements = try await engine.arrange(job.request)
                guard !Task.isCancelled, epoch == self.epoch,
                      job.request.generation == latestGeneration else { continue }
                job.completion(job.request, placements)
            } catch { /* Cancellation never publishes a partial layout. */ }
        }
    }

    func cancel() {
        epoch += 1
        pending = nil
        task?.cancel()
        task = nil
    }
}

@MainActor struct LayoutJob {
    typealias Completion = @MainActor (LayoutRequest, [MarkerPlacement]) -> Void
    let request: LayoutRequest
    let completion: Completion
}
