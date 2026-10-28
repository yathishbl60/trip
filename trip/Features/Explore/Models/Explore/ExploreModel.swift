import TripRouting
import TripDomain
import Observation

@MainActor @Observable final class ExploreModel {
    let configuration: MapConfiguration
    let camera: CameraModel
    let catalog: CatalogModel
    let filters: FilterModel
    let layout: LayoutModel
    let location: LocationModel
    let directions: DirectionsModel
    var environment: ExploreEnvironment
    let selection = PlaceSelectionModel()
    let appearance = MapAppearanceModel()
    var selectedPlace: Place? { selection.place }
    var isActive = false
    @ObservationIgnored var isSuspended = false
    @ObservationIgnored var activationRevision = 0

    init(configuration: MapConfiguration = .init(), provider: any PlaceProviding = ApplePlaceProvider(),
         environment: ExploreEnvironment = .init()) {
        self.configuration = configuration
        camera = CameraModel(configuration: configuration)
        catalog = CatalogModel(provider: provider, policy: configuration.data)
        filters = FilterModel(categories: configuration.availableCategories, selected: configuration.initialCategories)
        layout = LayoutModel(motion: configuration.motion)
        location = LocationModel(coordinate: configuration.validCenter, label: configuration.startingPointLabel)
        directions = DirectionsModel()
        self.environment = environment
        configureDirections()
    }

    func start() async {
        guard !Task.isCancelled, !isActive || isSuspended || !catalog.canSearch else { return }
        activationRevision += 1
        let revision = activationRevision
        isSuspended = false
        isActive = true
        camera.isMoving = false
        catalog.canSearch = false
        catalog.cancelSearch()
        await load(revision: revision)
        guard !Task.isCancelled, isActive, revision == activationRevision else { return }
        catalog.canSearch = true
        resumeVisibleContent()
    }

    func filterPlaces() {
        filters.updateCounts(catalog.visibleCounts)
        requestProjection()
    }

    func stop() {
        activationRevision += 1
        isSuspended = true
        isActive = false
        catalog.cancelSearch()
        catalog.autocomplete.cancel()
        layout.stop()
        location.stop()
        directions.suspend()
        directions.cancelRouteFit()
    }
}
