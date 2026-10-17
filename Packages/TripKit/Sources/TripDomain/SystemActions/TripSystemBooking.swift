import Foundation

/// The reviewed booking fields allowed to leave Trip. Private notes never enter this projection.
public nonisolated struct TripSystemBooking: Codable, Equatable, Identifiable, Sendable {
    public let tripID: UUID
    public let eventID: UUID
    public let title: String
    public let location: String
    public let start: Date?
    public let end: Date?
    public let timeZoneID: String
    public let travelAllowanceMinutes: Int?
    public var id: String { "\(tripID.uuidString):\(eventID.uuidString)" }
    public var timeZone: TimeZone { TimeZone(identifier: timeZoneID) ?? .gmt }
    public var canExportCalendar: Bool {
        guard let start, let end else { return false }
        return end > start
    }

    public init?(event: TripEvent, trip: TripPlan) {
        guard event.dayRange(in: trip) != nil, !trip.needsTimeZoneReview, event.clockIssue == nil else { return nil }
        tripID = trip.id
        eventID = event.id
        title = event.title
        location = event.location
        start = event.departureTime?.instant
        end = event.arrivalTime?.instant
        timeZoneID = event.departureTime?.zoneID ?? trip.calendar.timeZone.identifier
        travelAllowanceMinutes = event.travelAllowanceMinutes
    }

    public var deepLink: URL {
        var components = URLComponents()
        components.scheme = "trip"
        components.host = "trip"
        components.path = "/\(tripID.uuidString)"
        components.queryItems = [URLQueryItem(name: "surface", value: "detail"),
                                 URLQueryItem(name: "item", value: eventID.uuidString)]
        return components.url ?? URL(filePath: "/")
    }

    public var suggestedAlarmDate: Date? {
        start?.addingTimeInterval(-Double(max(0, travelAllowanceMinutes ?? 0)) * 60)
    }
}
