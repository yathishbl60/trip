#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation
import MapKit

public nonisolated struct DirectionsOptions: Equatable, Sendable {
    public init() {}

    public var avoidsTolls = false
    public var avoidsHighways = false
    public var avoidsBusyRoads = false
    public var avoidsHills = false
    public var avoidsStairs = false
    public var transitPreferences: Set<TransitPreference> = []
    public var timing = DirectionsTiming.now
    public var date = Date.now

    func apply(to request: MKDirections.Request, mode: TravelMode) {
        if mode.supportsAvoidance {
            request.tollPreference = avoidsTolls ? .avoid : .any
            request.highwayPreference = avoidsHighways ? .avoid : .any
        }
        switch timing {
        case .now: request.departureDate = .now
        case .departAt: request.departureDate = date
        case .arriveBy: request.arrivalDate = date
        }
    }
}

public nonisolated enum TransitPreference: String, CaseIterable, Identifiable, Sendable {
    case bus, subway, commuter, ferry
    public var id: Self { self }
    public var title: String { rawValue.capitalized }
}

public nonisolated enum DirectionsTiming: String, CaseIterable, Identifiable, Sendable {
    case now, departAt, arriveBy
    public var id: Self { self }

    public var title: String {
        switch self {
        case .now: TripText.leaveNow.text
        case .departAt: TripText.departAt.text
        case .arriveBy: TripText.arriveBy.text
        }
    }
}
