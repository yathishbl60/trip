import TripDomain
import Foundation

extension TripDay {
    var draftDistance: Measurement<UnitLength> {
        let meters = zip(stops, stops.dropFirst()).reduce(0.0) {
            $0 + $1.0.place.coordinate.distance(to: $1.1.place.coordinate)
        }
        return Measurement(value: meters, unit: .meters)
    }
}
