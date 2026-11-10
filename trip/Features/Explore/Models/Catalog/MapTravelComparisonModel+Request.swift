import Foundation
import TripRouting

nonisolated struct MapTravelSelection: Hashable {
    let ids: Set<String>
    let originID: String
    let mode: TravelMode
    let revision: Int
}

nonisolated struct MapTravelTaskID: Hashable {
    let selection: MapTravelSelection
    let isActive: Bool
}

extension MapTravelComparisonModel {
    func fetch(_ key: MapTravelKey) async throws -> DirectionsEstimate {
        let provider = provider
        return try await withThrowingTaskGroup(of: DirectionsEstimate.self) { group in
            group.addTask {
                try await provider.estimate(from: key.origin, to: key.destination, mode: key.mode)
            }
            group.addTask {
                try await Task.sleep(for: .seconds(15))
                throw URLError(.timedOut)
            }
            defer { group.cancelAll() }
            guard let result = try await group.next() else { throw CancellationError() }
            return result
        }
    }
}
