#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

public nonisolated struct TripDay: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var number: Int
    public var stops: [TripStop] = []
    public var notes = ""
    public var schedule: TripDaySchedule?
    public var itemOrder: [UUID] = []

    public init(number: Int) {
        id = UUID()
        self.number = number
    }

    public var title: String { TripText.dayTitle(number).text }
    public var placeCountText: String { TripText.placeCount(stops.count).text }
    public var summary: String { stops.isEmpty ? TripText.addPlacesToPlanThisDay.text : placeCountText }

    private enum CodingKeys: String, CodingKey { case id, number, stops, notes, schedule, itemOrder }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        number = try values.decode(Int.self, forKey: .number)
        stops = try values.decode([TripStop].self, forKey: .stops)
        notes = try values.decodeIfPresent(String.self, forKey: .notes) ?? ""
        schedule = try values.decodeIfPresent(TripDaySchedule.self, forKey: .schedule)
        itemOrder = try values.decodeIfPresent([UUID].self, forKey: .itemOrder) ?? []
    }
}

public nonisolated struct TripStop: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public let place: Place
    public var notes = ""
    public var timing = TripStopTiming()

    public init(place: Place) {
        id = UUID()
        self.place = place
    }

    private enum CodingKeys: String, CodingKey { case id, place, notes, timing }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        place = try values.decode(Place.self, forKey: .place)
        notes = try values.decodeIfPresent(String.self, forKey: .notes) ?? ""
        timing = try values.decodeIfPresent(TripStopTiming.self, forKey: .timing) ?? TripStopTiming()
    }
}
