import Foundation
import SwiftUI
import Testing
import TripDomain
@testable import trip

@MainActor struct TripDetailRouteTests {
    @Test func mapRoutesRetainTheExactDayAndDistinctVisitIdentity() {
        let tripID = UUID(), dayID = UUID()
        let first = TripDetailRoute(tripID: tripID, dayID: dayID)
        let reopened = TripDetailRoute(tripID: tripID, dayID: dayID)
        let overview = TripDetailRoute(tripID: tripID, destination: .map)
        #expect(first.destination == .map && first.dayID == dayID)
        #expect(overview.dayID == nil && first != reopened)
        #expect(TripDetailRoute.sameDestination(first, reopened))
        #expect(!TripDetailRoute.sameDestination(first, overview))
    }

    @Test func staleBackCannotDismissTheSameSectionAfterReopening() {
        let plan = TripPlan(title: "Weekend")
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [plan])
        model.request(.section(plan.id, .checklist))
        let previous = TripController(model: model.trips).detailRoute(for: plan.id)
        model.request(.section(plan.id, .itinerary))
        model.request(.section(plan.id, .checklist))
        previous.wrappedValue = nil
        #expect(model.trips.presentation.detailRoute?.destination == .checklist)
    }

    @Test func repeatingTheCurrentSectionPreservesItsVisitAndSearch() {
        let plan = TripPlan(title: "Weekend")
        let model = AppNavigationTestFixtures.model(store: NavigationTestStore(), plans: [plan])
        model.request(.section(plan.id, .details))
        let route = model.trips.presentation.detailRoute
        model.trips.lookup.setSearchText("museum")
        model.request(.section(plan.id, .details))
        #expect(model.trips.presentation.detailRoute == route)
        #expect(model.trips.lookup.searchText == "museum")
    }
}
