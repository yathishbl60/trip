#if DEBUG && canImport(trip)
import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite("Saved data and privacy", .serialized)
struct TripSavedDataCoverageTests {
    @Test("Spoken and shared detail text excludes private notes")
    func privacy() throws {
        var plan = TripJourneyPreview.plan()
        plan.notes = "PRIVATE_TRIP_NOTE"
        plan.days[0].notes = "PRIVATE_DAY_NOTE"
        plan.days[0].stops[0].notes = "PRIVATE_PLACE_NOTE"
        plan.events[0].notes = "PRIVATE_BOOKING_NOTE"
        let results = TripDetailQuery().results(in: TripSurfacePlan(plan))
        let text = TripItineraryDescription.text(plan) + results.map(\.shareText).joined()
        #expect(!text.contains("PRIVATE_"))
        #expect(text.contains(plan.events[0].title))
        #expect(text.contains(plan.days[0].stops[0].place.name))
        let first = try #require(results.first)
        #expect(!first.source.isEmpty)
    }

    @Test("Search combines category, day and text without duplicating multi-day stays")
    func combinedSearch() throws {
        let plan = TripJourneyPreview.plan()
        let surface = TripSurfacePlan(plan)
        let allStays = TripDetailQuery(category: .stays).results(in: surface)
        let lastDay = TripDetailQuery(category: .stays, dayNumber: 4, searchText: "Riverside").results(in: surface)
        #expect(allStays.count == 1)
        #expect(lastDay.map(\.id) == allStays.map(\.id))
        #expect(TripDetailQuery(category: .travel, dayNumber: 4, searchText: "Riverside").results(in: surface).isEmpty)
    }

    @Test("Saved detail identity never resolves in another trip")
    func detailIdentity() throws {
        let plan = TripJourneyPreview.plan()
        let id = try #require(plan.events.first?.id)
        let identity = TripDetailIdentity(tripID: plan.id, itemID: id)
        #expect(TripDetailIdentity(identity.rawValue) == identity)
        #expect(identity.resolve(in: TripSurfacePlan(plan))?.id == id)
        #expect(identity.resolve(in: TripSurfacePlan(TripPlan(title: "Other"))) == nil)
        #expect(TripDetailIdentity(identity.rawValue + "/extra") == nil)
    }

    @Test("Visit timing changes preserve unspecified values and repeat safely")
    func visitTiming() throws {
        var plan = TripJourneyPreview.plan()
        let stop = plan.days[0].stops[0]
        let change = TripVisitTimingChange(visitMinutes: 75)
        #expect(try change.apply(to: &plan, stopID: stop.id))
        #expect(plan.days[0].stops[0].timing.travelMinutes == stop.timing.travelMinutes)
        #expect(plan.days[0].stops[0].timing.bufferMinutes == stop.timing.bufferMinutes)
        #expect(plan.days[0].stops[0].timing.arrivalMinute == stop.timing.arrivalMinute)
        #expect(try change.apply(to: &plan, stopID: stop.id) == false)
        let bookingID = plan.events[0].id
        #expect(throws: TripVisitTimingError.self) {
            try change.apply(to: &plan, stopID: bookingID)
        }
    }
}
#endif
