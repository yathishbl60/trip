import Foundation
import MapKit
import TripDomain

extension PlaceNearbySearchModel {
    func fetch(_ scope: NearbySearchScope) async throws -> [Place] {
        guard origin.coordinate.isValid else { return [] }
        let diameter = scope.radius.rawValue * 2
        let region = MKCoordinateRegion(center: origin.coordinate.location,
                                        latitudinalMeters: diameter, longitudinalMeters: diameter)
        return try await withThrowingTaskGroup(of: [Place].self) { group in
            group.addTask { try await MapSearchService.nearby(region: region, category: scope.category) }
            group.addTask {
                try await Task.sleep(for: .seconds(15))
                throw URLError(.timedOut)
            }
            defer { group.cancelAll() }
            return try await group.next() ?? []
        }
    }
}
