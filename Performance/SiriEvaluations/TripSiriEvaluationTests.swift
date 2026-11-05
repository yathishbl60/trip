import SiriEvaluations
import Testing

@Suite("Trip Siri", .serialized)
struct TripSiriEvaluationTests {
    static let navigation = TripSiriEvaluation(name: "Trip navigation", dataset: TripSiriReadScenarios.navigation)
    static let savedData = TripSiriEvaluation(name: "Saved trip reads", dataset: SiriScenarioLoader {
        TripSiriReadScenarios.itinerary
        TripSiriReadScenarios.checklist
    }, requiresFixture: true)
    static let onscreen = TripSiriEvaluation(name: "Visible trip context", dataset: SiriScenarioLoader {
        TripSiriReadScenarios.onscreen
    }, requiresFixture: true, showsTrip: true)
    static let skills = TripSiriEvaluation(name: "Trip app skills", dataset: SiriScenarioLoader {
        TripSiriSkillScenarios.planning
        TripSiriSkillScenarios.preparation
        TripSiriSkillScenarios.booking
    })

    @Test("Navigation uses the requested surface", .evaluates(navigation))
    func navigationTools() {
        #expect(EvaluationContext.current.result.aggregateValue(.mean(of: .intentsAllPass)) == 1.0)
    }

    @Test("Read-only requests resolve the exact trip", .evaluates(savedData))
    func savedTripReads() {
        let result = EvaluationContext.current.result
        #expect(result.aggregateValue(.mean(of: .intentsAllPass)) == 1.0)
        #expect(result.aggregateValue(.mean(of: .foundEntitiesAllPass)) == 1.0)
    }

    @Test("This trip resolves the visible entity", .evaluates(onscreen))
    func visibleTripContext() {
        let result = EvaluationContext.current.result
        #expect(result.aggregateValue(.mean(of: .intentsAllPass)) == 1.0)
        #expect(result.aggregateValue(.mean(of: .onScreenEntitiesAllPass)) == 1.0)
    }

    @Test("Each multi-step task loads its app skill", .evaluates(skills))
    func appSkills() {
        let result = EvaluationContext.current.result
        #expect(result.aggregateValue(.mean(of: .skillsLoadedAllPass)) == 1.0)
        #expect(result.aggregateValue(.mean(of: .intentsAllPass)) == 1.0)
    }
}
