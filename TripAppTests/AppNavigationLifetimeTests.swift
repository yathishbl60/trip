import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite(.timeLimit(.minutes(1))) struct AppNavigationLifetimeTests {
    @Test func userTabChoiceSupersedesSlowRestoration() async {
        let store = NavigationTestStore()
        let model = AppNavigationTestFixtures.model(store: store)
        let plan = TripPlan(title: "Restored")
        let restoration = Task { await model.restore(tab: "trips", tripID: plan.id.uuidString, initialTripID: nil) }
        await store.waitForLoad()
        model.selectTab(.explore)
        await store.finish([plan])
        await restoration.value
        #expect(model.navigation.tab == .explore)
        #expect(model.trips.selectedTripID == nil)
    }

    @Test func newerRequestSupersedesPendingURL() async throws {
        let store = NavigationTestStore()
        let model = AppNavigationTestFixtures.model(store: store)
        let first = TripPlan(title: "First"), second = TripPlan(title: "Second")
        model.openURL(try #require(URL(string: "trip://trip/\(first.id)")))
        let previous = model.navigation.requestTask
        await store.waitForLoad()
        model.request(.savedTrip(second.id))
        let current = model.navigation.requestTask
        await store.finish([first, second])
        await previous?.value
        await current?.value
        #expect(model.trips.selectedTripID == second.id)
    }

    @Test func editorOpenedDuringLoadingPreventsDelivery() async throws {
        let store = NavigationTestStore()
        let model = AppNavigationTestFixtures.model(store: store)
        let plan = TripPlan(title: "Requested")
        model.request(.savedTrip(plan.id))
        let delivery = model.navigation.requestTask
        await store.waitForLoad()
        let draft = TripEditDraft()
        draft.title = "Unsaved"
        model.trips.presentation.editDraft = draft
        await store.finish([plan])
        await delivery?.value
        #expect(model.trips.presentation.editDraft === draft && draft.title == "Unsaved")
        #expect(draft.error != nil && model.trips.selectedTripID == nil)
    }
}
