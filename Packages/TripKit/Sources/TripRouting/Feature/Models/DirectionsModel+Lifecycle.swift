#if os(iOS) || os(visionOS)
import Foundation
import TripDomain

extension DirectionsModel {
    func clearResults() {
        routes = []
        selectedID = nil
        transitEstimate = nil
    }

    func prepareContext() {
        let context = DirectionsContext(origin: origin, places: destinationPlaces.map(\.coordinate), mode: mode)
        if context != routeContext {
            clearResults()
            presentation.needsRouteFraming = presentation.followsRoute
        }
        routeContext = context
    }

    public func fail(_ message: String) {
        cancel()
        clearResults()
        status = .unavailable(message)
        revision += 1
    }

    func startDeadline(_ duration: Duration, message: String) {
        let generation = generation
        deadline = Task { [weak self] in
            do {
                try await Task.sleep(for: max(duration, .seconds(1)))
                guard let self, !Task.isCancelled, generation == self.generation else { return }
                fail(message)
            } catch { /* A response or replacement cancels this deadline. */ }
        }
    }

    func completeArrival() -> Bool {
        guard stops.isEmpty, let origin, let destination, origin.distance(to: destination.coordinate) < 5 else { return false }
        clearResults()
        transitEstimate = DirectionsEstimate(travelTime: 0, distance: 0, arrival: .now)
        status = .ready
        return true
    }

    public func acceptLocation(_ coordinate: Coordinate) {
        guard isPresented, canCalculate, startingPoint.usesCurrentLocation, origin == nil, coordinate.isValid else { return }
        startingPoint.location = coordinate
        refresh()
    }

    func retry() {
        if startingPoint.usesCurrentLocation {
            startingPoint.reset(authorized: environment.locationAuthorized(), coordinate: environment.currentLocation())
        }
        refresh()
    }

    public func suspend() {
        canCalculate = false
        cancel()
        stopSearch.stop()
    }

    public func resume() {
        canCalculate = true
        if isPresented { retry() }
        if let session = presentation.placePicker { searchPlaces(stopSearch.query, session: session) }
    }
}

nonisolated struct DirectionsContext: Equatable {
    let origin: Coordinate?
    let places: [Coordinate]
    let mode: TravelMode
}
#endif
