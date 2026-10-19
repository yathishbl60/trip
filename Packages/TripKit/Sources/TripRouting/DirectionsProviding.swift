import MapKit
import Foundation

@MainActor public protocol DirectionsProviding {
    func calculate(_ request: MKDirections.Request, etaOnly: Bool) async throws -> DirectionsResponse
    func cancel()
}

public enum DirectionsResponse {
    case routes([MKRoute])
    case estimate(MKDirections.ETAResponse)
}

@MainActor public final class MapDirectionsService: DirectionsProviding {
    private var active: [UUID: MKDirections] = [:]
    public init() {}

    public func calculate(_ request: MKDirections.Request, etaOnly: Bool) async throws -> DirectionsResponse {
        let id = UUID()
        let calculation = MKDirections(request: request)
        active[id] = calculation
        defer { active[id] = nil }
        return try await withTaskCancellationHandler {
            try Task.checkCancellation()
            if etaOnly { return .estimate(try await calculation.calculateETA()) }
            return .routes(try await calculation.calculate().routes)
        } onCancel: {
            Task { @MainActor [weak self] in self?.cancel(id) }
        }
    }

    private func cancel(_ id: UUID) { active.removeValue(forKey: id)?.cancel() }

    public func cancel() {
        for calculation in active.values { calculation.cancel() }
        active.removeAll()
    }
}
