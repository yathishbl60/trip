import Testing
import TripDomain

struct TripSavedPlaceIndexTests {
    @Test func sharedPlaceRetainsEveryDayAndCollectionLink() {
        let first = fixture("First"), second = fixture("Second")
        let index = TripSavedPlaceIndex([first, second])
        let references = index.places("museum")
        #expect(references.count == 4 && Set(references.map(\.id)).count == 4)
        #expect(Set(references.map(\.tripID)) == [first.id, second.id])
        #expect(references.filter { $0.dayNumber == 1 }.count == 2)
        #expect(references.filter { $0.containerTitle == "Shortlist" }.count == 2)
        #expect(index.places("missing").isEmpty)
    }

    @Test func renameMoveAndDeleteReplaceOnlyTheChangedTrip() {
        var first = fixture("First")
        let second = fixture("Second")
        var index = TripSavedPlaceIndex([first, second])
        let unchanged = index.places("museum").filter { $0.tripID == second.id }
        first.title = "Renamed"
        first.days[0].number = 3
        first.collections = []
        index.replace(first)
        #expect(index.places("museum").filter { $0.tripID == second.id } == unchanged)
        let changed = index.places("museum").filter { $0.tripID == first.id }
        #expect(changed.count == 1 && changed[0].tripTitle == "Renamed" && changed[0].dayNumber == 3)
        index.remove(first.id)
        #expect(index.places("museum") == unchanged)
        index.remove(second.id)
        #expect(index.places("museum").isEmpty)
    }

    @Test func replacingTheSameSnapshotDoesNotDuplicateMemberships() {
        let plan = fixture("Trip")
        var index = TripSavedPlaceIndex([plan])
        let original = index.places("museum")
        index.replace(plan)
        index.replace(plan)
        #expect(index.places("museum") == original)
    }

    private func fixture(_ title: String) -> TripPlan {
        let place = Place(id: "museum", name: "Museum", coordinate: .bangkok, category: .museum,
                          importance: 1, rating: nil, reviews: nil)
        var plan = TripPlan(title: title)
        plan.days[0].stops = [TripStop(place: place)]
        var collection = TripCollection(title: "Shortlist")
        collection.stops = [TripStop(place: place)]
        plan.collections = [collection]
        return plan
    }
}
