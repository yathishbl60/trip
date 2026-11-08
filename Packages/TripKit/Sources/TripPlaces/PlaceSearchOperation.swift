import MapKit
import TripDomain

/// A request keeps its own cancellation lifetime when a newer search replaces it.
@MainActor final class PlaceSearchOperation {
    private let search: MKLocalSearch
    private var isCancelled = false

    init(_ configuration: MKLocalSearch.Request) {
        search = MKLocalSearch(request: configuration)
    }

    func places() async throws -> [Place] {
        try await withTaskCancellationHandler {
            try Task.checkCancellation()
            guard !isCancelled else { throw CancellationError() }
            let response = try await search.start()
            try Task.checkCancellation()
            guard !isCancelled else { throw CancellationError() }
            return PlaceSearchResults.unique(response.mapItems.map(PlaceFactory.make))
        } onCancel: {
            Task { @MainActor in self.cancel() }
        }
    }

    func cancel() {
        isCancelled = true
        search.cancel()
    }
}
