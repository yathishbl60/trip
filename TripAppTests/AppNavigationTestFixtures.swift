import Foundation
import TripDomain
@testable import trip

@MainActor enum AppNavigationTestFixtures {
    static func model(store: any TripStoring, plans: [TripPlan]? = nil, packing: TripPackingModel? = nil) -> AppModel {
        let library = TripLibraryModel(store: store, loadedTrips: plans)
        let services = NavigationTestServices()
        let trips = TripModel(library: library, assistant: TripAssistantModel(client: client(services as any ItineraryPlanning)),
                              lookup: TripLookupModel(client: client(services as any TripDetailSearching)),
                              packing: packing ?? TripPackingModel(client: client(services as any TripPackingPlanning)),
                              stopOrdering: services,
                              bookingImport: TripBookingImportModel(reader: services),
                              systemActions: TripSystemActionsModel(service: NavigationTestSystemActions(), library: library),
                              weather: TripWeatherModel(service: services))
        return AppModel(explore: ExploreModel(provider: services), trips: trips)
    }

    private static func client<Service: Sendable>(_ service: Service) -> TripAIClient<Service> {
        TripAIClient(makeService: { _ in service },
                     availability: { _ in "Unavailable in navigation tests" }, failureMessage: { _ in "Unavailable" })
    }
}

extension NavigationTestServices: ItineraryPlanning, TripPackingPlanning, TripDetailSearching {
    func generate(places: [Place], preferences: String, dayCount: Int) async throws -> [TripDay] {
        throw NavigationTestFailure.unexpectedService
    }
    func suggestions(for context: TripPackingContext, preferences: String) async throws -> [String] {
        throw NavigationTestFailure.unexpectedService
    }
    func interpret(_ question: String, days: [TripSurfaceDay], now: Date) async throws -> TripDetailQuery {
        throw NavigationTestFailure.unexpectedService
    }
}

nonisolated enum NavigationTestFailure: Error { case unexpectedService }

nonisolated struct NavigationTestServices: PlaceProviding, TripBookingReading, TripStopOrderSuggesting, TripWeatherProviding {
    func initialPlaces() async throws -> [Place] { [] }
    func search(_ request: PlaceSearchRequest) async throws -> [Place] { [] }
    func read(_ document: TripBookingDocument) async throws -> TripBookingProposal { throw NavigationTestFailure.unexpectedService }
    func suggestion(for day: TripDay) async throws -> TripStopOrderProposal { throw NavigationTestFailure.unexpectedService }
    func forecast(at coordinate: Coordinate, during interval: DateInterval) async throws -> TripWeatherForecast {
        throw NavigationTestFailure.unexpectedService
    }
}
