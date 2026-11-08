import TripLocalization
import TripDomain
import CoreLocation

extension LocationModel {
    func updates(generation: Int) async {
        guard !Task.isCancelled, generation == self.generation else { return }
        let session = CLServiceSession(authorization: .whenInUse)
        defer {
            session.invalidate()
            if generation == self.generation { isFollowing = false }
        }
        do {
            for try await update in CLLocationUpdate.liveUpdates() {
                try Task.checkCancellation()
                guard generation == self.generation else { return }
                if !accept(update) { return }
            }
        } catch {
            if !Task.isCancelled, generation == self.generation { status = TripText.locationIsTemporarilyUnavailable.text }
        }
    }

    private func accept(_ update: CLLocationUpdate) -> Bool {
        if update.authorizationDenied || update.authorizationDeniedGlobally || update.authorizationRestricted {
            isLive = false
            timestamp = nil
            status = update.authorizationRestricted ? TripText.locationAccessIsRestrictedOnThisDevice.text
                : TripText.enableLocationServicesAndAllowTripLocationAccessIn.text
            return false
        }
        guard let fix = update.location, fix.horizontalAccuracy >= 0,
              abs(fix.timestamp.timeIntervalSinceNow) < 60 else { return true }
        let coordinate = Coordinate(fix.coordinate)
        guard coordinate.isValid else { return true }
        if self.coordinate != coordinate { self.coordinate = coordinate }
        timestamp = fix.timestamp
        isLive = true
        status = TripText.yourLocation.text
        return true
    }
}
