import Foundation

enum TripVisitTimingChecks {
    static func run() throws {
        try preservesUnspecifiedValues()
        try arrivalChanges()
        try rejectsInvalidValues()
        try rejectsAmbiguousClocks()
    }

    private static func preservesUnspecifiedValues() throws {
        var plan = TripJourneyFixtures.plan()
        plan.days[0].stops[0].notes = "Keep private notes"
        let original = plan.days[0].stops[0]
        let events = plan.events
        let edit = TripVisitTimingChange(visitMinutes: 120, travelMinutes: 20)
        let applied = try edit.apply(to: &plan, stopID: original.id)
        try require(applied, "Timing edit did not apply")
        let changed = plan.days[0].stops[0]
        try require(changed.timing.visitMinutes == 120 && changed.timing.travelMinutes == 20, "Requested allowances lost")
        try require(changed.timing.bufferMinutes == original.timing.bufferMinutes, "Unspecified buffer changed")
        try require(changed.timing.arrivalMinute == original.timing.arrivalMinute, "Unspecified arrival changed")
        try require(changed.notes == original.notes && plan.events == events, "Timing edit changed unrelated data")
        let repeated = try edit.apply(to: &plan, stopID: original.id)
        try require(!repeated, "Repeated timing edit was not idempotent")
    }

    private static func arrivalChanges() throws {
        var plan = TripJourneyFixtures.plan()
        _ = plan.reviewTimeZone("Asia/Tokyo", departure: TripLocalDate(year: 2026, month: 11, day: 5))
        let id = plan.days[0].stops[0].id
        try TripVisitTimingChange(arrivalTime: "00:30", nextDay: true).apply(to: &plan, stopID: id)
        try require(plan.days[0].stops[0].timing.arrivalMinute == 1470, "Next-day arrival used device time")
        try TripVisitTimingChange(flexibleArrival: true).apply(to: &plan, stopID: id)
        try require(plan.days[0].stops[0].timing.arrivalMinute == nil, "Flexible arrival retained a fixed clock")
    }

    private static func rejectsInvalidValues() throws {
        let edits = [TripVisitTimingChange(), .init(visitMinutes: 4), .init(travelMinutes: -1),
                     .init(bufferMinutes: 181), .init(arrivalTime: "24:00"), .init(arrivalTime: "9:00"),
                     .init(arrivalTime: "10:60"), .init(arrivalTime: "10:00", flexibleArrival: true), .init(nextDay: true)]
        for edit in edits { try rejects(edit, in: TripJourneyFixtures.plan()) }
        let plan = TripJourneyFixtures.plan()
        try rejects(.init(visitMinutes: 60), in: plan, id: plan.events[0].id)
        try rejects(.init(visitMinutes: 60), in: plan, id: UUID())
    }

    private static func rejectsAmbiguousClocks() throws {
        var plan = TripJourneyFixtures.plan()
        _ = plan.reviewTimeZone("America/New_York", departure: TripLocalDate(year: 2026, month: 11, day: 1))
        try rejects(.init(arrivalTime: "01:30"), in: plan)
        _ = plan.reviewTimeZone("America/New_York", departure: TripLocalDate(year: 2026, month: 3, day: 8))
        try rejects(.init(arrivalTime: "02:30"), in: plan)
    }

    private static func rejects(_ edit: TripVisitTimingChange, in source: TripPlan, id: UUID? = nil) throws {
        var plan = source
        let stopID = id ?? plan.days[0].stops[0].id
        do {
            try edit.apply(to: &plan, stopID: stopID)
            try require(false, "Invalid visit timing was accepted")
        } catch is TripVisitTimingError {
            try require(plan.days == source.days && plan.events == source.events, "Rejected timing edit was not atomic")
        }
    }
}
