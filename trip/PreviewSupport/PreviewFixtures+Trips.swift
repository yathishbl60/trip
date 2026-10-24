import TripDomain
#if DEBUG
extension PreviewFixtures {
    static func tripPlanner(includeChecklist: Bool = true) -> TripModel {
        var plan = TripPlan(title: "Bangkok weekend")
        plan.days[0].stops = [TripStop(place: hotel), TripStop(place: longName)]
        plan.days.append(TripDay(number: 2))
        var collection = TripCollection(title: "Favorite stays")
        collection.stops = [TripStop(place: hotel)]
        plan.collections = [collection]
        if includeChecklist {
            plan.checklist = TripChecklistTemplate.essentials.items.map { TripChecklistItem(title: $0) }
            plan.checklist[0].isComplete = true
        }
        return PreviewTripServices.makeTrips([plan])
    }

    static func emptyTripPlanner() -> TripModel {
        PreviewTripServices.makeTrips([])
    }
}
#endif
