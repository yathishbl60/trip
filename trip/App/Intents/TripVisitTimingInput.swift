import AppIntents
import TripDomain

@AppEntity(.generable)
struct TripVisitTimingInput {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { TypeDisplayRepresentation(name: "intent_visit_timing") }
    @Property(title: "visit_duration", description: "intent_timing_visit_minutes") var visitMinutes: Int?
    @Property(title: "travel_time", description: "intent_timing_travel_minutes") var travelMinutes: Int?
    @Property(title: "buffer", description: "intent_timing_buffer_minutes") var bufferMinutes: Int?
    @Property(title: "arrival_time", description: "intent_timing_arrival_clock") var arrivalTime: String?
    @Property(title: "next_day", description: "intent_timing_next_day") var nextDay: Bool?
    @Property(title: "intent_flexible_arrival", description: "intent_timing_flexible_arrival") var flexibleArrival: Bool?

    init() {}

    var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "intent_visit_timing") }

    var change: TripVisitTimingChange {
        TripVisitTimingChange(visitMinutes: visitMinutes, travelMinutes: travelMinutes, bufferMinutes: bufferMinutes,
                              arrivalTime: arrivalTime, nextDay: nextDay ?? false, flexibleArrival: flexibleArrival ?? false)
    }
}
