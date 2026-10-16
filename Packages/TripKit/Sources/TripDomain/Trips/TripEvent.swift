#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation

/// One event can appear on several days without duplicating its saved details.
public nonisolated struct TripEvent: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var kind: TripEventKind
    public var title: String
    public var startDayID: UUID
    public var endDayID: UUID
    public var startMinute: Int?
    public var endMinute: Int?
    public var departureTime: TripZonedDateTime? = nil
    public var arrivalTime: TripZonedDateTime? = nil
    public var travelAllowanceMinutes: Int? = nil
    public var location = ""
    public var arrivalLocation = ""
    public var notes = ""

    public init(kind: TripEventKind = .activity, title: String = "", dayID: UUID) {
        id = UUID()
        self.kind = kind
        self.title = title
        startDayID = dayID
        endDayID = dayID
    }
}

public nonisolated enum TripEventKind: String, Codable, CaseIterable, Sendable {
    case flight, train, stay, reservation, activity, freeTime

    public var title: String {
        switch self {
        case .flight: TripText.flight.text
        case .train: TripText.train.text
        case .stay: TripText.hotelStay.text
        case .reservation: TripText.reservation.text
        case .activity: TripText.personalActivity.text
        case .freeTime: TripText.freeTime.text
        }
    }

    public var symbol: String {
        switch self {
        case .flight: "airplane"
        case .train: "tram"
        case .stay: "bed.double"
        case .reservation: "ticket"
        case .activity: "figure.walk"
        case .freeTime: "sun.horizon"
        }
    }

    public var isTransport: Bool { self == .flight || self == .train }
    public var startLabel: String { self == .stay ? TripText.checkIn.text : (isTransport ? TripText.departure.text : TripText.start.text) }
    public var endLabel: String { self == .stay ? TripText.checkOut.text : (isTransport ? TripText.arrival.text : TripText.end.text) }
}
