import TripDomain
import TripIntelligence
import TripStorage

/// Production composition. Feature models never choose their own live services.
@MainActor enum AppTripServices {
    static func makeLibrary() -> TripLibraryModel {
        TripLibraryModel(store: TripStore())
    }

    static func makeTrips(library: TripLibraryModel, tracking: TripTrackingModel) -> TripModel {
        TripModel(library: library, assistant: makeAssistant(), lookup: makeLookup(),
                  packing: makePacking(), stopOrdering: TripStopOrderService(),
                  bookingImport: makeBookingImport(), systemActions: makeSystemActions(library: library),
                  weather: TripWeatherModel(service: weather), tracking: tracking)
    }

    static func makeAssistant() -> TripAssistantModel {
        TripAssistantModel(client: TripAIClient<any ItineraryPlanning>(
            makeService: { TripPlanningService(processing: $0) },
            availability: availability, failureMessage: TripAIFailure.itineraryMessage))
    }

    static func makeLookup() -> TripLookupModel {
        TripLookupModel(client: TripAIClient<any TripDetailSearching>(
            makeService: { TripDetailSearchService(processing: $0) },
            availability: availability, failureMessage: TripAIFailure.lookupMessage))
    }

    private static func makePacking() -> TripPackingModel {
        TripPackingModel(client: TripAIClient<any TripPackingPlanning>(
            makeService: { _ in TripPackingService() },
            availability: TripAIAvailability.issue, failureMessage: TripAIFailure.packingMessage))
    }

    private static func availability(_ processing: TripAIProcessing) -> String? {
        TripAIConfiguration.issue(for: processing) ?? TripAIAvailability.issue(for: processing)
    }
}
