import Foundation

enum TripSystemActionChecks {
    static func run() throws {
        try exactIdentity()
        try navigation()
        try filteredIdentity()
        try savedAnswers()
    }

    private static func exactIdentity() throws {
        let trip = TripJourneyFixtures.plan()
        let plan = TripSurfacePlan(trip)
        let id = TripDetailIdentity(tripID: trip.id, itemID: trip.events[0].id)
        try require(TripDetailIdentity(id.rawValue) == id, "Detail identity did not round trip")
        try require(id.resolve(in: plan)?.item.id == trip.events[0].id, "Detail opened another record")
        let copy = TripSurfacePlan(TripPlan(copying: trip))
        try require(id.resolve(in: copy) == nil, "Detail identity crossed trip boundaries")
        var removed = trip
        removed.events.removeFirst()
        try require(id.resolve(in: TripSurfacePlan(removed)) == nil, "Deleted detail still resolved")
        for invalid in ["", trip.id.uuidString, id.rawValue + "/extra", "/", "wrong/wrong"] {
            try require(TripDetailIdentity(invalid) == nil, "Malformed detail identity accepted")
        }
    }

    private static func navigation() throws {
        let plan = TripSurfacePlan(TripJourneyFixtures.plan())
        let first = TripDayBriefing(plan: plan, date: plan.days[0].date)
        let middle = TripDayBriefing(plan: plan, date: plan.days[1].date)
        let last = TripDayBriefing(plan: plan, date: plan.days.last!.date)
        try require(first.previousDate == nil && first.nextDate == plan.days[1].date, "First-day boundaries failed")
        try require(middle.previousDate == first.date && middle.nextDate == plan.days[2].date, "Day navigation skipped a day")
        try require(last.nextDate == nil, "Snippet offered a day beyond the itinerary")
        let outside = TripDayBriefing(plan: plan, date: plan.startDate.addingTimeInterval(-86_400))
        try require(outside.previousDate == nil && outside.nextDate == nil, "Unknown date offered invented navigation")
    }

    private static func filteredIdentity() throws {
        let plan = TripSurfacePlan(TripJourneyFixtures.plan())
        let stay = plan.days[0].agenda.first { $0.kind == .stay }!
        let results = TripDetailQuery(itemID: stay.id).results(in: plan)
        try require(results.count == 1 && results[0].item.id == stay.id, "Exact-detail query duplicated a stay")
        let wrong = TripDetailQuery(category: .travel, itemID: stay.id).results(in: plan)
        try require(wrong.isEmpty, "Identity bypassed selected category")
        try require(TripDetailQuery(itemID: UUID()).results(in: plan).isEmpty, "Unknown identity substituted a result")
    }

    private static func savedAnswers() throws {
        var trip = TripJourneyFixtures.plan()
        trip.notes = "PRIVATE_TRIP_NOTE"
        trip.events[1].notes = "PRIVATE_STAY_NOTE"
        let plan = TripSurfacePlan(trip)
        let answer = TripDetailAnswer(plan: plan, query: TripDetailQuery(category: .stays, dayNumber: 2))
        try require(answer.results.count == 1 && answer.results[0].id == trip.events[1].id, "Answer lost spanning stay")
        try require(answer.summary.contains(trip.events[1].title), "Spoken answer omitted saved title")
        try require(!answer.summary.contains("PRIVATE_"), "Private notes leaked into answer")
        let shared = answer.results[0].shareText
        try require(!shared.contains("PRIVATE_") && shared.contains(answer.results[0].source), "Shared detail lost provenance or privacy")
        let missing = TripDetailAnswer(plan: plan, query: TripDetailQuery(dayNumber: 29))
        try require(missing.results.isEmpty, "Answer substituted a missing day")
        let unsupported = TripDetailAnswer(plan: plan, query: TripDetailQuery(category: .unsupported))
        try require(unsupported.results.isEmpty, "Unsupported request exposed unrelated details")
        trip.events.removeAll()
        let removed = TripDetailAnswer(plan: TripSurfacePlan(trip), query: answer.query)
        try require(removed.results.isEmpty, "Refreshed answer retained a deleted stay")
    }
}
