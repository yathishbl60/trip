import Foundation

@MainActor enum ProjectionReadinessChecks {
    static func run() async throws {
        let model = LayoutModel()
        defer { model.stop() }
        model.retryProjection()
        let first = model.projectionRetryTask
        model.retryProjection()
        try require(model.projectionAttempts == 1, "Readiness retries were not coalesced")
        await first?.value
        try require(model.projectionRevision == 1, "Map readiness did not request a fresh live projection")
        try await cancellation(model)
        try await viewport(model)
        model.projectionAttempts = 30
        model.retryProjection()
        try require(model.projectionRetryTask == nil, "Unavailable map retried indefinitely")
        model.projectionReady()
        try require(model.projectionAttempts == 0, "Successful projection did not reset readiness")
        print("PASS: initial projection retries are bounded, coalesced, and cancelled on suspension")
    }

    private static func cancellation(_ model: LayoutModel) async throws {
        let revision = model.projectionRevision
        model.retryProjection()
        let task = model.projectionRetryTask
        model.stop()
        await task?.value
        try require(task?.isCancelled == true && model.projectionRevision == revision,
                    "A hidden map published a delayed projection request")
    }

    private static func viewport(_ model: LayoutModel) async throws {
        let revision = model.projectionRevision
        model.viewportSettled()
        let superseded = model.viewportTask
        model.viewportSettled()
        let latest = model.viewportTask
        await superseded?.value
        await latest?.value
        try require(superseded?.isCancelled == true && model.projectionRevision == revision + 1,
                    "Sheet movement requested multiple transient layouts")
    }
}
