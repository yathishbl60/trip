import Foundation

/// Adapt hotels, activities, people, or trips to stable Place IDs at this boundary.
public nonisolated protocol PlaceProviding: Sendable {
    func initialPlaces() async throws -> [Place]
    func search(_ request: PlaceSearchRequest) async throws -> [Place]
}
