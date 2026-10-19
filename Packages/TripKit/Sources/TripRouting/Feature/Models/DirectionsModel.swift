#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import Observation
import Foundation
import TripDomain

@MainActor @Observable public final class DirectionsModel {
    var destination: Place?
    let startingPoint = DirectionsOriginModel()
    var origin: Coordinate? { startingPoint.coordinate }
    var stops: [Place] = []
    var mode = TravelMode.driving
    var options = DirectionsOptions()
    var routes: [DirectionsRoute] = []
    var selectedID: String?
    var transitEstimate: DirectionsEstimate?
    var status = DirectionsStatus.idle
    public internal(set) var revision = 0
    let stopSearch = DirectionsStopSearchModel()
    let presentation: DirectionsPresentationModel
    let configuration: DirectionsConfiguration
    var environment: DirectionsEnvironment
    @ObservationIgnored let provider: any DirectionsProviding
    @ObservationIgnored var task: Task<Void, Never>?
    @ObservationIgnored var deadline: Task<Void, Never>?
    @ObservationIgnored var framingTask: Task<Void, Never>?
    @ObservationIgnored var generation = 0
    @ObservationIgnored var canCalculate = true
    @ObservationIgnored var routeContext: DirectionsContext?

    public init(configuration: DirectionsConfiguration = .init(), environment: DirectionsEnvironment = .init(),
         provider: any DirectionsProviding = MapDirectionsService()) {
        self.configuration = configuration
        self.environment = environment
        self.provider = provider
        presentation = DirectionsPresentationModel(compactHeight: configuration.compactHeight)
        mode = configuration.modes.first ?? .driving
    }

    public func begin(_ destination: Place, origin: Coordinate?) {
        self.destination = destination
        startingPoint.reset(authorized: environment.locationAuthorized(), coordinate: origin)
        stops = []
        presentation.reset()
        stopSearch.reset()
        refresh()
    }

    func refresh(debounced: Bool = false) {
        cancel()
        guard canCalculate, destination != nil else { return }
        prepareContext()
        revision += 1
        guard prepareOrigin() else { return }
        if completeArrival() { return }
        status = .loading
        startDeadline(configuration.requestTimeout, message: TripText.directionsTookTooLongTryAgain.text)
        startCalculation(generation: generation, debounced: debounced)
    }

    func cancel() {
        generation += 1
        task?.cancel()
        deadline?.cancel()
        task = nil
        deadline = nil
        provider.cancel()
    }

    public func dismiss() {
        cancel()
        destination = nil
        startingPoint.reset()
        stops = []
        clearResults()
        routeContext = nil
        presentation.reset()
        stopSearch.reset()
        status = .idle
        revision += 1
    }

    func select(_ id: String) {
        guard status == .ready, selectedID != id, routes.contains(where: { $0.id == id }) else { return }
        selectedID = id
        presentation.needsRouteFraming = true
        presentation.followsRoute = true
        revision += 1
    }
}

nonisolated enum DirectionsStatus: Equatable {
    case idle, choosingOrigin, waitingForLocation, loading, ready, unavailable(String)
}
#endif
