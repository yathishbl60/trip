#if DEBUG && canImport(trip)
import Foundation
import SwiftUI
import Testing
import TripDomain
@testable import trip

@MainActor @Suite("Trip wayfinding", .serialized)
struct TripWayfindingTests {
    @Test("A stale Back binding cannot dismiss a newer destination")
    func staleDismissal() throws {
        let model = PreviewFixtures.tripPlanner()
        let id = try #require(model.library.trips.first?.id)
        model.openSection(.checklist, tripID: id)
        let previous = TripController(model: model).detailRoute(for: id)
        model.openSection(.today, tripID: id)
        previous.wrappedValue = nil
        #expect(model.presentation.detailRoute?.destination == .today)
        TripController(model: model).detailRoute(for: id).wrappedValue = nil
        #expect(model.presentation.detailRoute == nil)
        #expect(model.selectedTripID == id)
    }

    @Test("Day map handoff retains the requested day")
    func dayMap() throws {
        let model = PreviewFixtures.app()
        let plan = try #require(model.trips.library.trips.first)
        let day = try #require(plan.days.last)
        model.request(.dayTool(plan.id, day.id, .map))
        #expect(model.trips.presentation.detailRoute?.dayID == day.id)
        #expect(model.trips.presentation.detailRoute?.destination == .map)
        model.request(.savedTrip(plan.id))
        #expect(model.trips.presentation.detailRoute == nil)
        #expect(model.trips.selectedTripID == plan.id)
    }

    @Test("Navigation preserves an unsaved draft")
    func protectsDraft() throws {
        let model = PreviewFixtures.app()
        let id = try #require(model.trips.library.trips.first?.id)
        model.request(.savedTrip(id))
        model.trips.beginEdit(id)
        let draft = try #require(model.trips.presentation.editDraft)
        draft.title = "Unsaved travel plans"
        model.request(.section(id, .today))
        model.request(.trips)
        #expect(model.trips.presentation.editDraft === draft)
        #expect(draft.title == "Unsaved travel plans")
        #expect(draft.error != nil)
        #expect(model.trips.selectedTripID == id)
        #expect(model.trips.presentation.detailRoute == nil)
    }

    @Test("A missing trip preserves the current destination")
    func missingTrip() throws {
        let model = PreviewFixtures.app()
        let id = try #require(model.trips.library.trips.first?.id)
        model.request(.section(id, .checklist))
        model.request(.section(UUID(), .today))
        #expect(model.trips.selectedTripID == id)
        #expect(model.trips.presentation.detailRoute?.destination == .checklist)
        #expect(model.navigation.notice != nil)
    }

    @Test("Saved detail editing resolves the exact canonical booking")
    func savedBookingEditor() throws {
        let model = TripJourneyPreview.planner()
        let plan = try #require(model.library.trips.first)
        let booking = try #require(plan.events.last)
        model.editSavedDetail(booking.id, tripID: plan.id)
        #expect(model.presentation.eventDraft?.original?.id == booking.id)
        #expect(model.presentation.eventDraft?.tripID == plan.id)
        #expect(model.presentation.stopTiming == nil)
    }
}
#endif
