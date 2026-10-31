import TripLocalization
import Foundation
import TripDomain

struct TripPlaceAddition {
    let stop: TripStop
    let dayID: UUID
    let dayTitle: String
    var message: String { TripText.valueAddedToValue(stop.place.name, dayTitle).text }
}
