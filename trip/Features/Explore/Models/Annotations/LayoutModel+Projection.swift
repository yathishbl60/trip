import Foundation

extension LayoutModel {
    /// Only plain state crosses the delay; the next MapReader callback supplies a fresh proxy.
    func retryProjection() {
        guard projectionRetryTask == nil, projectionAttempts < ProjectionScheduling.readinessAttemptLimit else { return }
        projectionAttempts += 1
        projectionRetryTask = Task { [weak self] in
            try? await Task.sleep(for: ProjectionScheduling.readinessRetryDelay)
            guard let self, !Task.isCancelled else { return }
            projectionRetryTask = nil
            invalidateProjection()
        }
    }

    func projectionReady() {
        projectionRetryTask?.cancel()
        projectionRetryTask = nil
        projectionAttempts = 0
    }

    func viewportSettled() {
        cancelPending()
        viewportTask?.cancel()
        viewportTask = Task { [weak self] in
            try? await Task.sleep(for: ProjectionScheduling.sheetSettlingDelay)
            guard let self, !Task.isCancelled else { return }
            invalidateProjection()
            viewportTask = nil
        }
    }
}

private nonisolated enum ProjectionScheduling {
    // Give MapKit up to three seconds to become projectable, without an unbounded retry loop.
    static let readinessAttemptLimit = 30
    static let readinessRetryDelay = Duration.milliseconds(100)
    // Coalesce intermediate sheet frames before requesting new collision geometry.
    static let sheetSettlingDelay = Duration.milliseconds(180)
}
