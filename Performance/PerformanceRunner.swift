import Foundation

@main @MainActor enum PerformanceRunner {
    static func main() async throws {
        let arguments = CommandLine.arguments
        guard arguments.count == 3, ["all", "check", "benchmark", "system-check"].contains(arguments[1]) else {
            throw CheckFailure(description: "Usage: performance-runner all|check|benchmark|system-check report.json")
        }
        let mode = arguments[1]
        if mode == "system-check" {
            try TripSystemProjectionChecks.run()
            print("PASS: system projections, privacy, saved actions, civil dates, DST, date-line travel, legacy migration, Today")
            return
        }
        if mode != "benchmark" { try await check() }
        guard mode != "check" else { return }
        let metrics = try await benchmark()
        let report = BenchmarkReport(checksPassed: mode == "all", metrics: metrics)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(report).write(to: URL(fileURLWithPath: arguments[2]), options: .atomic)
    }

    private static func check() async throws {
        try SpatialChecks.grid()
        try SpatialChecks.wrapping()
        try SpatialChecks.searchAndZoom()
        try IndexChecks.run()
        try dataChecks()
        try await PlaceCollectionChecks.cancellation()
        try SearchCoverageChecks.run()
        try AnnotationChoiceChecks.run()
        try CameraFeedbackChecks.run()
        try CameraNavigationChecks.run()
        try ZoomInteractionChecks.run()
        try MarkerAppearanceChecks.run()
        try await ProjectionLifecycleChecks().run()
        try await MarkerTransitionChecks.run()
        try await LayoutChecks.run()
        try await SchedulerChecks().run()
        print("PASS: spatial hash, geographic index, merging, layouts, selection, reservations, cancellation, scheduling, itineraries")
    }

    private static func dataChecks() throws {
        try DataChecks.merging()
        try DataChecks.identity()
        try DataChecks.policies()
        try SearchCacheChecks.run()
        try SearchHistoryChecks.run()
        try TripScheduleChecks.run()
        try TripItineraryRevisionChecks.run()
        try TripJourneyChecks.run()
        try TripSystemProjectionChecks.run()
    }

    private static func benchmark() async throws -> [BenchmarkMetric] {
        let geographic = try GeographicBenchmarks.run()
        let layout = try await LayoutBenchmarks().run()
        let metrics = geographic + layout
        for metric in metrics { metric.display() }
        return metrics
    }
}
