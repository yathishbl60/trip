import Observation
import Foundation
import TripDomain

nonisolated enum AppTab: String, Hashable { case explore, trips }
nonisolated enum AppDestination: Hashable {
    case explore, trips, newTrip, savedTrip(UUID), draftTrip(UUID, String, Int, TripAIProcessing)
    case findTrip(UUID, String)
    case savedDetail(TripDetailIdentity)
    case checklist(UUID, String?)
    case searchPlace(TripPlaceSearchRequest)
    case importBooking(TripBookingImportRequest)
    case section(UUID, TripSection), workspaceTool(UUID, TripWorkspaceTool)
    case dayTool(UUID, UUID, TripDayTool), editDetail(TripDetailIdentity)
    case newEvent(TripNewEventRequest)
}

@MainActor @Observable final class AppNavigationModel {
    var tab = AppTab.trips
    var isActive = false
    var didRestore = false
    var notice: String?
    @ObservationIgnored var linkTask: Task<Void, Never>?
}

@MainActor @Observable final class AppLaunchModel {
    static let shared = AppLaunchModel()
    var destination: AppDestination?
    var revision = 0

    func open(_ destination: AppDestination) {
        self.destination = destination
        revision += 1
    }
}
