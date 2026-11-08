import TripDomain
#if DEBUG
extension PreviewFixtures {
    static func tripPlanner(includeChecklist: Bool = true) -> TripModel {
        PreviewTripServices.makeTrips([tripPlan(includeChecklist: includeChecklist)])
    }

    static func checklist(includeChecklist: Bool = true) -> TripChecklistModel {
        PreviewTripServices.makeChecklist([tripPlan(includeChecklist: includeChecklist)])
    }

    static func collections() -> TripCollectionsModel {
        PreviewTripServices.makeCollections([tripPlan(includeChecklist: false)])
    }

    private static func tripPlan(includeChecklist: Bool) -> TripPlan {
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
        return plan
    }

    static func emptyTripPlanner() -> TripModel {
        PreviewTripServices.makeTrips([])
    }
}
#endif
