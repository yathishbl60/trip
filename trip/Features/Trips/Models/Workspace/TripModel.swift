import TripDomain
import Observation

/// Composes the trip workflows without owning app navigation or map state.
@MainActor @Observable final class TripModel {
    let library: TripLibraryModel
    let presentation = TripPresentationModel()
    let assistant: TripAssistantModel
    let tracking: TripTrackingModel
    let feedback = TripFeedbackModel()
    let lookup: TripLookupModel
    let packing: TripPackingModel
    let bookingImport: TripBookingImportModel
    let systemActions: TripSystemActionsModel
    let weather: TripWeatherModel
    let stopOrdering: any TripStopOrderSuggesting
    var environment: TripEnvironment
    var onlyTrip: TripPlan? { library.trips.count == 1 ? library.trips.first : nil }

    var hasEditingSession: Bool {
        presentation.hasEditingSession || bookingImport.isPresented || bookingImport.wantsEventReview
            || systemActions.presentation != nil || weather.reviewDestination != nil
    }

    init(library: TripLibraryModel, assistant: TripAssistantModel, lookup: TripLookupModel,
         packing: TripPackingModel, stopOrdering: any TripStopOrderSuggesting,
         bookingImport: TripBookingImportModel, systemActions: TripSystemActionsModel, weather: TripWeatherModel,
         environment: TripEnvironment = .init(), tracking: TripTrackingModel = TripTrackingModel()) {
        self.lookup = lookup
        self.packing = packing
        self.stopOrdering = stopOrdering
        self.bookingImport = bookingImport
        self.systemActions = systemActions
        self.weather = weather
        self.library = library
        self.assistant = assistant
        self.tracking = tracking
        self.environment = environment
        prepareTracking()
    }

    private func prepareTracking() {
        tracking.prepare = { [weak library] in
            await library?.flush()
            if library?.saveError != nil { throw TripTrackingError.saveFailed }
        }
    }

    func chooseDestination(for place: Place) {
        dismissDestination()
        presentation.notice = nil
        presentation.pendingPlace = place
    }

    func dismissDestination() {
        if let draft = presentation.planning, draft.isInsertion { closePlanning(draft.id) }
        if presentation.editDraft?.placeToSave != nil { presentation.editDraft = nil }
        presentation.pendingPlace = nil
    }
}
