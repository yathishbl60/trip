import TripLocalization
import Foundation

nonisolated enum TripTrackingError: LocalizedError {
    case saveFailed
    var errorDescription: String? {
        TripText.saveYourLatestTripChangesBeforeStartingDayTracking.text
    }
}
