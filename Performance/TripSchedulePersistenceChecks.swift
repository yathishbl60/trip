import Foundation

enum TripSchedulePersistenceChecks {
    static func run() throws {
        try legacyPayload()
        try roundTrip()
        try bounds()
    }

    private static func legacyPayload() throws {
        let day = TripScheduleFixtures.day()
        let encoded = try JSONEncoder().encode(day)
        var object = try JSONSerialization.jsonObject(with: encoded) as! [String: Any]
        object.removeValue(forKey: "schedule")
        var stops = object["stops"] as! [[String: Any]]
        for index in stops.indices { stops[index].removeValue(forKey: "timing") }
        object["stops"] = stops
        let payload = try JSONSerialization.data(withJSONObject: object)
        let restored = try JSONDecoder().decode(TripDay.self, from: payload)
        try require(restored.schedule == nil, "Legacy day enabled scheduling")
        try require(restored.id == day.id && restored.stops.map(\.id) == day.stops.map(\.id), "Migration changed identities")
        try require(restored.stops.allSatisfy { $0.timing == TripStopTiming() }, "Legacy visit defaults missing")
    }

    private static func roundTrip() throws {
        var day = TripScheduleFixtures.day()
        day.notes = "Day notes"
        day.stops[1].notes = "Private notes"
        day.stops[1].timing.arrivalMinute = 1500
        let restored = try JSONDecoder().decode(TripDay.self, from: JSONEncoder().encode(day))
        try require(restored.schedule == day.schedule && restored.notes == day.notes, "Schedule persistence lost")
        try require(restored.stops[1].timing == day.stops[1].timing, "Visit settings did not round-trip")
        try require(restored.stops[1].notes == day.stops[1].notes, "Visit settings replaced notes")
        let copy = restored.stops[1].timing.unpinned
        try require(copy.arrivalMinute == nil && copy.visitMinutes == day.stops[1].timing.visitMinutes,
                    "Copy should preserve duration without copying a reservation")
    }

    private static func bounds() throws {
        var timing = TripStopTiming()
        timing.arrivalMinute = Int.max
        timing.visitMinutes = Int.min
        timing.travelMinutes = Int.max
        timing.bufferMinutes = Int.min
        let normalized = timing.normalized
        try require(normalized.arrivalMinute == 2879 && normalized.visitMinutes == 5, "Invalid arrival/duration retained")
        try require(normalized.travelMinutes == 720 && normalized.bufferMinutes == 0, "Invalid allowances retained")
        let payload = Data(#"{"startMinute":-100,"endMinute":9999}"#.utf8)
        let schedule = try JSONDecoder().decode(TripDaySchedule.self, from: payload)
        try require(schedule.startMinute == 0 && schedule.endMinute == 1439, "Decoded schedule not normalized")
        let stop = try JSONDecoder().decode(TripStopTiming.self, from: Data("{}".utf8))
        try require(stop == TripStopTiming(), "Partial timing payload lost defaults")
    }
}
