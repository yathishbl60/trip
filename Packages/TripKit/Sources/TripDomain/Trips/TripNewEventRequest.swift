import Foundation
#if !TRIP_STANDALONE
import TripLocalization
#endif

public nonisolated struct TripNewEventRequest: Hashable, Sendable {
    public let tripID: UUID
    public let dayID: UUID
    public let kind: TripEventKind
    public let title: String

    public init(trip: TripPlan, dayID: UUID, kind: TripEventKind, title: String = "") throws {
        tripID = trip.id
        self.dayID = dayID
        self.kind = kind
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        try validate(in: trip)
    }

    public func validate(in trip: TripPlan) throws {
        guard trip.id == tripID else { throw TripNewEventError.missingTrip }
        guard trip.days.contains(where: { $0.id == dayID }) else { throw TripNewEventError.missingDay }
        guard trip.events.count < TripLimits.events else { throw TripNewEventError.full }
        guard title.count <= TripLimits.titleCharacters,
              title.unicodeScalars.allSatisfy({ !CharacterSet.controlCharacters.contains($0) }) else {
            throw TripNewEventError.invalidTitle
        }
    }
}

public nonisolated enum TripNewEventError: LocalizedError, CustomLocalizedStringResourceConvertible, Equatable {
    case missingTrip, missingDay, full, invalidTitle
    public var errorDescription: String? { String(localized: localizedStringResource) }

    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .missingTrip: TripText.thisTripIsNoLongerAvailable.resource
        case .missingDay: TripText.thisDayIsNoLongerAvailable.resource
        case .full: TripText.thisTripHasReachedItsEventLimit.resource
        case .invalidTitle: TripText.newEventTitleInvalid.resource
        }
    }
}
