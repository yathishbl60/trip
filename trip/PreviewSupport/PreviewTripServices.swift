#if DEBUG
import TripDomain

/// Component previews use local services, independent of disk and AI availability.
@MainActor enum PreviewTripServices {
    static func makeTrips(_ plans: [TripPlan], tracking: TripTrackingModel = TripTrackingModel(),
                          environment: TripEnvironment = .init()) -> TripModel {
        let library = TripLibraryModel(store: PreviewTripStore(plans), loadedTrips: plans)
        let assistant = TripAssistantModel(client: client(PreviewItineraryPlanner() as any ItineraryPlanning))
        let packing = TripPackingModel(client: client(PreviewPackingPlanner() as any TripPackingPlanning))
        return TripModel(library: library, assistant: assistant, lookup: makeLookup(), packing: packing,
                         stopOrdering: PreviewStopOrderService(),
                         bookingImport: TripBookingImportModel(reader: PreviewBookingReader()),
                         systemActions: TripSystemActionsModel(service: PreviewSystemActionProvider(), library: library),
                         weather: TripWeatherModel(service: PreviewTripWeatherService()),
                         environment: environment, tracking: tracking)
    }

    static func makeLookup() -> TripLookupModel {
        TripLookupModel(client: client(PreviewDetailSearch() as any TripDetailSearching))
    }

    static func makeChecklist(_ plans: [TripPlan]) -> TripChecklistModel {
        let library = TripLibraryModel(store: PreviewTripStore(plans), loadedTrips: plans)
        let packing = TripPackingModel(client: client(PreviewPackingPlanner() as any TripPackingPlanning))
        return TripChecklistModel(library: library, packing: packing)
    }

    static func makeCollections(_ plans: [TripPlan]) -> TripCollectionsModel {
        let library = TripLibraryModel(store: PreviewTripStore(plans), loadedTrips: plans)
        return TripCollectionsModel(library: library)
    }

    private static func client<Service: Sendable>(_ service: Service) -> TripAIClient<Service> {
        TripAIClient(makeService: { _ in service }, availability: { _ in nil },
                     failureMessage: { _ in "Local preview request failed." })
    }
}
#endif
