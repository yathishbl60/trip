import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite(.timeLimit(.minutes(1))) struct AppRestorationTests {
    @Test func restorationFailureUsesTheLibraryRecoveryUI() async {
        let model = AppNavigationTestFixtures.model(store: FailingNavigationStore())
        await model.restore(tab: "explore", tripID: "", initialTripID: nil)
        #expect(model.trips.library.loadError != nil && !model.navigation.didRestore)
        #expect(model.navigation.notice == nil && model.navigation.tab == .trips)
    }

    @Test func explicitRequestFailureReportsAnUnavailableDestination() async {
        let model = AppNavigationTestFixtures.model(store: FailingNavigationStore())
        model.request(.savedTrip(UUID()))
        await model.navigation.requestTask?.value
        #expect(model.trips.library.loadError != nil && model.navigation.notice != nil)
        #expect(model.trips.selectedTripID == nil)
    }

    @Test func canceledRestorationCanRetryOnActivation() async {
        let plan = TripPlan(title: "Restored"), store = NavigationTestStore()
        let model = AppNavigationTestFixtures.model(store: store)
        let task = Task { await model.restore(tab: "explore", tripID: plan.id.uuidString, initialTripID: nil) }
        await store.waitForLoad()
        task.cancel()
        await store.finish([plan])
        await task.value
        #expect(!model.navigation.didRestore && model.trips.selectedTripID == nil)
        await model.restore(tab: "explore", tripID: plan.id.uuidString, initialTripID: nil)
        #expect(model.navigation.didRestore && model.navigation.tab == .explore)
        #expect(model.trips.selectedTripID == plan.id)
    }
}

private actor FailingNavigationStore: TripStoring {
    func load() async throws -> [TripPlan] { throw NavigationTestFailure.unexpectedService }
    func save(_ trips: [TripPlan], revision: Int, changedIDs: Set<UUID>?) async throws {}
}
