import SiriEvaluations
import Testing

struct TripSiriEvaluation: Evaluation {
    let name: String
    let dataset: SiriScenarioLoader
    var requiresFixture = false
    var showsTrip = false

    func subject(from sample: SiriScenario) async throws -> SiriScenarioSubject {
        if requiresFixture { try await TripSiriFixture.validate() }
        if showsTrip { try await TripSiriFixture.showTrip() }
        return try await SiriService.run(scenario: sample)
    }

    var evaluators: Evaluators { SiriExpectationEvaluator() }

    func aggregateMetrics(using aggregator: inout MetricsAggregator) {
        Self.computeSiriMetrics(into: &aggregator)
    }
}
