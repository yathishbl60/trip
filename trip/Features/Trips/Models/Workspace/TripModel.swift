import TripDomain
import TripPlaces
import Observation

/// Composes the trip workflows without owning app navigation or map state.
@MainActor @Observable final class TripModel {
    let library: TripLibraryModel
    let presentation = TripPresentationModel()
    let assistant: TripAssistantModel
    let tracking: TripTrackingModel
    let feedback = TripFeedbackModel()
    let lookup: TripLookupModel
    let checklist: TripChecklistModel
    let collections: TripCollectionsModel
    let bookingImport: TripBookingImportModel
    let systemActions: TripSystemActionsModel
    let weather: TripWeatherModel
    let stopOrdering: any TripStopOrderSuggesting
    let makePlaceSearch: (@MainActor () -> any PlaceSearching)?
    var environment: TripEnvironment { didSet { configureWorkflows() } }
    var onlyTrip: TripPlan? { library.trips.count == 1 ? library.trips.first : nil }

    var hasEditingSession: Bool {
        presentation.hasEditingSession || checklist.hasEditingSession || collections.hasEditingSession
            || bookingImport.isPresented || bookingImport.wantsEventReview
            || systemActions.presentation != nil || weather.reviewDestination != nil
    }

    init(library: TripLibraryModel, assistant: TripAssistantModel, lookup: TripLookupModel,
         packing: TripPackingModel, stopOrdering: any TripStopOrderSuggesting,
         bookingImport: TripBookingImportModel, systemActions: TripSystemActionsModel, weather: TripWeatherModel,
         makePlaceSearch: (@MainActor () -> any PlaceSearching)? = nil,
         environment: TripEnvironment = .init(), tracking: TripTrackingModel = TripTrackingModel()) {
        self.lookup = lookup
        checklist = TripChecklistModel(library: library, packing: packing)
        collections = TripCollectionsModel(library: library)
        self.makePlaceSearch = makePlaceSearch
        self.stopOrdering = stopOrdering
        self.bookingImport = bookingImport
        self.systemActions = systemActions
        self.weather = weather
        self.library = library
        self.assistant = assistant
        self.tracking = tracking
        self.environment = environment
        configureWorkflows()
    }

    private func configureWorkflows() {
        tracking.prepare = { [weak library] in
            await library?.flush()
            if library?.saveError != nil { throw TripTrackingError.saveFailed }
        }
        configureChecklist()
        configureCollections()
    }

    func chooseDestination(for place: Place) {
        dismissDestination()
        presentation.notice = nil
        presentation.placeSave = TripPlaceSaveSession(place: place)
    }

    func dismissDestination() {
        if let draft = presentation.planning, draft.isInsertion { closePlanning(draft.id) }
        if presentation.editDraft?.placeToSave != nil { presentation.editDraft = nil }
        presentation.placeSave = nil
    }

    func dismissDestination(matching sessionID: TripPlaceSaveSession.ID) {
        guard presentation.placeSave?.id == sessionID else { return }
        dismissDestination()
    }
}
