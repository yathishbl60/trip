import Foundation
import Testing
import TripDomain

struct TripCollectionSchedulingTests {
    @Test func scheduleKeepsShortlistAndRetriesPreserveTheExistingVisit() throws {
        var plan = fixture()
        let source = plan.collections[0].stops[0]
        let identity = identity(plan)
        let dayID = plan.days[0].id
        let stopID = try TripCollectionScheduling.schedule(identity, on: dayID, in: &plan)
        #expect(stopID != source.id && plan.collections[0].stops[0] == source)
        #expect(plan.days[0].stops[0].notes.isEmpty && plan.days[0].stops[0].timing == TripStopTiming())
        plan.days[0].stops[0].notes = "Keep my visit notes"
        let repeated = try TripCollectionScheduling.schedule(identity, on: dayID, in: &plan)
        #expect(repeated == stopID && plan.days[0].stops.count == 1)
        #expect(plan.days[0].stops[0].notes == "Keep my visit notes")
    }

    @Test func missingOrForeignSourceCannotScheduleAnotherPlace() throws {
        var plan = fixture()
        let original = identity(plan)
        #expect(TripCollectionPlaceIdentity(original.rawValue) == original)
        #expect(TripCollectionPlaceIdentity(original.rawValue + "/extra") == nil)
        let other = fixture()
        let dayID = plan.days[0].id
        #expect(throws: TripCollectionSchedulingError.self) {
            try TripCollectionScheduling.schedule(identity(other), on: dayID, in: &plan)
        }
        plan.collections[0].stops = []
        #expect(throws: TripCollectionSchedulingError.self) {
            try TripCollectionScheduling.schedule(original, on: dayID, in: &plan)
        }
        #expect(plan.days[0].stops.isEmpty)
    }

    @Test func fullDayRejectsNewPlacesButAllowsAnIdempotentRetry() throws {
        var plan = fixture()
        let identity = identity(plan)
        let dayID = plan.days[0].id
        plan.days[0].stops = (0..<TripLimits.stops).map { _ in TripStop(place: place("other")) }
        #expect(throws: TripVisitMoveError.self) {
            try TripCollectionScheduling.schedule(identity, on: dayID, in: &plan)
        }
        let existing = TripStop(place: plan.collections[0].stops[0].place)
        plan.days[0].stops[0] = existing
        #expect(try TripCollectionScheduling.schedule(identity, on: dayID, in: &plan) == existing.id)
        #expect(plan.days[0].stops.count == TripLimits.stops)
        #expect(throws: TripVisitMoveError.self) {
            try TripCollectionScheduling.schedule(identity, on: UUID(), in: &plan)
        }
    }

    private func fixture() -> TripPlan {
        var plan = TripPlan(title: "Weekend")
        var collection = TripCollection(title: "Shortlist")
        var stop = TripStop(place: place("museum"))
        stop.notes = "Private shortlist note"
        stop.timing.visitMinutes = 90
        collection.stops = [stop]
        plan.collections = [collection]
        return plan
    }

    private func identity(_ plan: TripPlan) -> TripCollectionPlaceIdentity {
        TripCollectionPlaceIdentity(tripID: plan.id, collectionID: plan.collections[0].id,
                                    stopID: plan.collections[0].stops[0].id)
    }

    private func place(_ id: String) -> Place {
        Place(id: id, name: "Museum", coordinate: Coordinate(latitude: 13, longitude: 100),
              category: .museum, importance: 0, rating: nil, reviews: nil)
    }
}
