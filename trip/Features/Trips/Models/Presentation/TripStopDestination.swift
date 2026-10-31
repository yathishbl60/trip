import TripLocalization
import TripDomain

nonisolated enum TripStopDestination: String {
    case day, collection

    var duplicateMessage: String {
        switch self {
        case .day: TripText.thisPlaceIsAlreadyOnThatDay.text
        case .collection: TripText.thisPlaceIsAlreadyInThatCollection.text
        }
    }

    var capacityMessage: String {
        switch self {
        case .day: TripText.aDayCanHoldUpToValuePlaces(TripText.number(TripLimits.stops)).text
        case .collection: TripText.aCollectionCanHoldUpToValuePlaces(TripText.number(TripLimits.stops)).text
        }
    }
}
