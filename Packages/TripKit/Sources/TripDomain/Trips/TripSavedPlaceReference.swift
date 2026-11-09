import Foundation
#if !TRIP_STANDALONE
import TripLocalization
#endif

/// A lightweight link to canonical saved data; no booking details or notes are copied.
public nonisolated struct TripSavedPlaceReference: Identifiable, Hashable, Sendable {
    public let tripID: UUID
    public let tripTitle: String
    public let containerID: UUID
    public let containerTitle: String
    public let dayNumber: Int?
    public let stopID: UUID
    public let placeID: String
    public var id: String { "\(tripID)/\(containerID)/\(stopID)" }
    public var locationTitle: String { dayNumber.map { TripText.dayTitle($0).text } ?? containerTitle }
    public var title: String { TripText.savedToTripLocation(tripTitle, locationTitle).text }

    public init(trip: TripPlan, containerID: UUID, title: String, dayNumber: Int? = nil, stop: TripStop) {
        tripID = trip.id
        tripTitle = trip.title
        self.containerID = containerID
        containerTitle = title
        self.dayNumber = dayNumber
        stopID = stop.id
        placeID = stop.place.id
    }
}
