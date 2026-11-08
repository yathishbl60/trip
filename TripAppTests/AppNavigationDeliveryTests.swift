import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite(.timeLimit(.minutes(1))) struct AppNavigationDeliveryTests {
    @Test func missingTripURLPreservesTabAndSelection() throws {
        let plan = TripPlan(title: "Current")
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [plan])
        model.request(.savedTrip(plan.id))
        model.selectTab(.explore)
        model.openURL(try #require(URL(string: "trip://trip/\(UUID())")))
        #expect(model.navigation.tab == .explore && model.trips.selectedTripID == plan.id)
        #expect(model.navigation.notice != nil)
    }

    @Test func deletedDayRequestPreservesCurrentSection() {
        let plan = TripPlan(title: "Current")
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [plan])
        model.request(.section(plan.id, .today))
        let route = model.trips.presentation.detailRoute
        model.request(.dayTool(plan.id, UUID(), .map))
        #expect(model.trips.presentation.detailRoute == route)
        #expect(model.navigation.notice != nil)
    }

    @Test func onlyPreferredActiveWindowConsumesLaunchOnce() {
        let first = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [])
        let second = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [])
        first.navigation.isActive = true
        second.navigation.isActive = true
        let mailbox = AppLaunchModel()
        mailbox.open(.explore)
        first.consumeLaunch(from: mailbox, preferredSceneID: second.navigation.id)
        #expect(mailbox.pending != nil && first.navigation.tab == .trips)
        second.consumeLaunch(from: mailbox, preferredSceneID: second.navigation.id)
        let generation = second.navigation.generation
        second.consumeLaunch(from: mailbox, preferredSceneID: second.navigation.id)
        #expect(mailbox.pending == nil && second.navigation.tab == .explore)
        #expect(second.navigation.generation == generation)
    }

    @Test func inactiveWindowKeepsRequestForLaterDelivery() {
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [])
        let mailbox = AppLaunchModel()
        mailbox.open(.explore)
        model.consumeLaunch(from: mailbox, preferredSceneID: model.navigation.id)
        #expect(mailbox.pending != nil)
        model.navigation.isActive = true
        model.consumeLaunch(from: mailbox, preferredSceneID: model.navigation.id)
        #expect(mailbox.pending == nil && model.navigation.tab == .explore)
    }

    @Test func loadingWindowRetainsTheLaunchUntilReady() async {
        let store = NavigationTestStore()
        let model = AppNavigationTestFixtures.model(store: store)
        let mailbox = AppLaunchModel()
        model.navigation.isActive = true
        mailbox.open(.explore)
        model.consumeLaunch(from: mailbox, preferredSceneID: model.navigation.id)
        #expect(mailbox.pending != nil)
        let load = Task { await model.trips.library.load() }
        await store.waitForLoad()
        await store.finish([])
        await load.value
        model.consumeLaunch(from: mailbox, preferredSceneID: model.navigation.id)
        #expect(mailbox.pending == nil && model.navigation.tab == .explore)
    }
}
