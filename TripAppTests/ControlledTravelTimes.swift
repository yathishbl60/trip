import Foundation
import TripDomain
import TripRouting

@MainActor final class ControlledTravelTimes: TravelTimeEstimating {
    private(set) var modes: [TravelMode] = []
    private var requests: [Int: CheckedContinuation<DirectionsEstimate, Never>] = [:]
    private var waiters: [Int: CheckedContinuation<Void, Never>] = [:]

    func estimate(from origin: Coordinate, to destination: Coordinate, mode: TravelMode) async throws -> DirectionsEstimate {
        let id = modes.count
        modes.append(mode)
        return await withCheckedContinuation {
            requests[id] = $0
            waiters.removeValue(forKey: id)?.resume()
        }
    }

    func waitForRequest(_ id: Int) async {
        if requests[id] != nil { return }
        await withCheckedContinuation { waiters[id] = $0 }
    }

    func finish(_ id: Int, seconds: Double) {
        requests.removeValue(forKey: id)?.resume(returning: DirectionsEstimate(travelTime: seconds, distance: 200, arrival: .now))
    }
}
