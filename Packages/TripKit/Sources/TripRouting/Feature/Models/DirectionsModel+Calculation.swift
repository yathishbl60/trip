#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import Foundation
import MapKit
import TripDomain

extension DirectionsModel {
    func calculate(generation: Int) async {
        guard generation == self.generation else { return }
        do {
            let places = destinationPlaces.map { RouteWaypoint(id: $0.id, name: $0.name, coordinate: $0.coordinate) }
            let plan = try DirectionsPlan(origin: origin, places: places, mode: mode, options: options)
            let responses = try await DirectionsCalculation(provider: provider).calculate(plan)
            guard !Task.isCancelled, generation == self.generation else { return }
            try accept(responses)
        } catch {
            guard !Task.isCancelled, generation == self.generation else { return }
            fail(message(for: error))
        }
        if generation == self.generation { finishCalculation() }
    }

    private func finishCalculation() {
        deadline?.cancel()
        deadline = nil
        task = nil
    }

    private func message(for error: Error) -> String {
        if case .pastDate? = error as? DirectionsFailure { return TripText.chooseAFutureTimeOrSelectLeaveNow.text }
        if (error as? MKError)?.code == .loadingThrottled { return TripText.waitAMomentThenTryAgain.text }
        if error is DirectionsFailure || (error as? MKError)?.code == .directionsNotFound {
            return TripText.noRouteFoundTryAnotherTravelMode.text
        }
        return TripText.couldnTLoadDirectionsCheckYourConnectionAndTry.text
    }

    private func accept(_ responses: [DirectionsResponse]) throws {
        let estimates = responses.compactMap { if case .estimate(let value) = $0 { value } else { nil } }
        if let first = estimates.first, let last = estimates.last {
            transitEstimate = DirectionsEstimate(travelTime: last.expectedArrivalDate.timeIntervalSince(first.expectedDepartureDate),
                                                 distance: estimates.reduce(0) { $0 + $1.distance }, arrival: last.expectedArrivalDate)
        } else {
            let previousSelection = selectedID
            routes = try DirectionsRoute.alternatives(responses, arrival: arrival)
            setSelectedRoute(routes.first(where: { $0.id == previousSelection })?.id ?? routes.first?.id)
        }
        guard let estimate, estimate.isValid else { throw DirectionsFailure.unavailable }
        status = .ready
        revision += 1
    }

    func startCalculation(generation: Int, debounced: Bool) {
        task = Task { [weak self] in
            do {
                if debounced { try await Task.sleep(for: .milliseconds(250)) }
                await self?.calculate(generation: generation)
            } catch { /* Settings changes replace the pending route request. */ }
        }
    }

    private func arrival(for duration: TimeInterval) -> Date {
        switch options.timing {
        case .now: .now.addingTimeInterval(duration)
        case .departAt: options.date.addingTimeInterval(duration)
        case .arriveBy: options.date
        }
    }

}
#endif
