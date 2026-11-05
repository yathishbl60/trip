#if DEBUG && canImport(trip)
import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite("Trip booking drafts", .serialized)
struct TripEventEntryCoverageTests {
    @Test("Every kind opens a draft without saving", arguments: TripEventKind.allCases)
    func draftKinds(_ kind: TripEventKind) throws {
        let model = PreviewFixtures.app()
        let plan = try #require(model.trips.library.trips.first)
        let day = try #require(plan.days.last)
        let request = try TripNewEventRequest(trip: plan, dayID: day.id, kind: kind, title: "  Sample booking  ")
        model.request(.newEvent(request))
        let draft = try #require(model.trips.presentation.eventDraft)
        #expect(draft.event.kind == kind)
        #expect(draft.event.startDayID == day.id)
        #expect(draft.event.title == "Sample booking")
        #expect(model.trips.library.trip(plan.id)?.events.count == plan.events.count)
        TripController(model: model.trips).cancelEvent(draft)
        #expect(model.trips.presentation.eventDraft == nil)
        #expect(model.trips.library.trip(plan.id)?.events.count == plan.events.count)
    }

    @Test("A day removed after request validation cannot receive a draft")
    func removedDay() throws {
        let model = PreviewFixtures.app()
        let plan = try #require(model.trips.library.trips.first)
        let day = try #require(plan.days.last)
        let request = try TripNewEventRequest(trip: plan, dayID: day.id, kind: .stay)
        model.request(.section(plan.id, .today))
        model.trips.library.update(plan.id) { $0.days.removeAll { $0.id == day.id }; return true }
        model.request(.newEvent(request))
        #expect(model.trips.presentation.eventDraft == nil)
        #expect(model.trips.presentation.detailRoute?.destination == .today)
        #expect(model.navigation.notice != nil)
    }

    @Test("Event capacity is checked again at delivery")
    func capacityChanged() throws {
        var plan = TripPlan(title: "Capacity review")
        let day = plan.days[0].id
        let request = try TripNewEventRequest(trip: plan, dayID: day, kind: .flight)
        plan.events = (0..<TripLimits.events).map { TripEvent(title: "Booking \($0)", dayID: day) }
        #expect(throws: TripNewEventError.full) { try request.validate(in: plan) }
    }

    @Test("Wrong trip and invalid titles are rejected")
    func invalidInput() throws {
        let plan = TripPlan(title: "Input review")
        let request = try TripNewEventRequest(trip: plan, dayID: plan.days[0].id, kind: .activity)
        #expect(throws: TripNewEventError.missingTrip) { try request.validate(in: TripPlan(title: "Other")) }
        #expect(throws: TripNewEventError.missingDay) {
            try TripNewEventRequest(trip: plan, dayID: UUID(), kind: .activity)
        }
        #expect(throws: TripNewEventError.invalidTitle) {
            try TripNewEventRequest(trip: plan, dayID: plan.days[0].id, kind: .activity, title: "Two\nlines")
        }
    }

    @Test("A new booking cannot replace an existing edit")
    func preservesDraft() throws {
        let model = PreviewFixtures.app()
        let plan = try #require(model.trips.library.trips.first)
        model.trips.beginEdit(plan.id)
        let draft = try #require(model.trips.presentation.editDraft)
        model.request(.newEvent(try TripNewEventRequest(trip: plan, dayID: plan.days[0].id, kind: .stay)))
        #expect(model.trips.presentation.editDraft === draft)
        #expect(model.trips.presentation.eventDraft == nil)
        #expect(draft.error != nil)
    }
}
#endif
