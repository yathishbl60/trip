import Foundation
import MapEngine
import Observation
import TripDomain

nonisolated enum SavedMapScope: Hashable {
    case all, saved, trip(UUID)
}

nonisolated struct SavedMapRequest: Equatable {
    let groups: [TripSavedPlaceGroup]
    let scope: SavedMapScope
    let query: String

    @concurrent func snapshot() async throws -> CatalogSnapshot {
        let selected = groups.filter {
            if case .trip(let id) = scope { return $0.id == id }
            return true
        }
        var seen = Set<String>()
        let places = selected.flatMap(\.places).filter { seen.insert($0.id).inserted }
        try Task.checkCancellation()
        return CatalogSnapshot(PlaceSearchQuery(query).places(in: places))
    }
}

@MainActor @Observable final class SavedMapModel {
    var scope: SavedMapScope = .all
    private(set) var snapshot = CatalogSnapshot([])
    private(set) var isLoading = false
    var isActive: Bool { scope != .all }

    func choose(_ scope: SavedMapScope) {
        self.scope = scope
        snapshot = CatalogSnapshot([])
        isLoading = isActive
    }

    func load(_ request: SavedMapRequest) async -> Bool {
        isLoading = true
        defer { if !Task.isCancelled { isLoading = false } }
        guard let result = try? await request.snapshot(), !Task.isCancelled else { return false }
        snapshot = result
        return true
    }
}
