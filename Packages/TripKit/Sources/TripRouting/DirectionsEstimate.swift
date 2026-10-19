#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation
import MapKit

public nonisolated struct DirectionsEstimate {
    public let travelTime: TimeInterval
    public let distance: Double
    public let arrival: Date

    var isValid: Bool {
        travelTime.isFinite && travelTime >= 0 && distance.isFinite && distance >= 0
            && arrival.timeIntervalSince1970.isFinite
    }

    public init(travelTime: TimeInterval, distance: Double, arrival: Date) {
        self.travelTime = travelTime
        self.distance = distance
        self.arrival = arrival
    }

    public var durationText: String {
        guard travelTime.isFinite, travelTime >= 0 else { return TripText.unavailable.text }
        if travelTime == 0 { return TripText.arrived.text }
        let seconds = max(60, ceil(travelTime / 60) * 60)
        return Duration.seconds(seconds).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }

    public var arrivalText: String {
        arrival.formatted(date: Calendar.current.isDateInToday(arrival) ? .omitted : .abbreviated, time: .shortened)
    }

    public var distanceText: String {
        Measurement(value: distance, unit: UnitLength.meters).formatted(.measurement(width: .abbreviated, usage: .road))
    }
}
