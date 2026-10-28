import TripLocalization
import TripDomain
import CoreLocation
import Observation
import Foundation

@MainActor @Observable final class LocationModel {
    var coordinate = Coordinate.bangkok
    var isLive = false
    var timestamp: Date?
    var status = TripText.bangkokStartingPoint.text
    var isFollowing = false
    @ObservationIgnored var wantsUpdates = false
    @ObservationIgnored var generation = 0
    @ObservationIgnored var task: Task<Void, Never>?
    @ObservationIgnored private let authorization = CLLocationManager()

    init(coordinate: Coordinate = .bangkok, label: String = TripText.bangkokStartingPoint.text) {
        self.coordinate = coordinate
        status = label
    }

    var currentCoordinate: Coordinate? {
        guard isAuthorized, isLive, let timestamp, abs(timestamp.timeIntervalSinceNow) < 60 else { return nil }
        return coordinate
    }

    var isAuthorized: Bool {
        let status = authorization.authorizationStatus
        #if os(iOS)
        return status == .authorizedWhenInUse || status == .authorizedAlways
        #else
        return status == .authorizedWhenInUse
        #endif
    }

    func start() {
        stop()
        wantsUpdates = true
        isFollowing = true
        let generation = generation
        task = Task { await updates(generation: generation) }
    }

    func stop() {
        task?.cancel()
        task = nil
        generation += 1
        isFollowing = false
    }
}
