import Foundation
import TripDomain

nonisolated enum AppWorkflowRequest: Hashable {
    case newTrip, draftTrip(UUID, String, Int, TripAIProcessing), findTrip(UUID, String)
    case checklist(UUID, String?), searchPlace(TripPlaceSearchRequest), importBooking(TripBookingImportRequest)
    case workspaceTool(UUID, TripWorkspaceTool), dayTool(UUID, UUID, TripDayTool)
    case editDetail(TripDetailIdentity), newEvent(TripNewEventRequest)
}

extension AppRequest {
    static let newTrip = Self(operation: .workflow(.newTrip))

    static func draftTrip(_ id: UUID, _ preferences: String, _ days: Int, _ processing: TripAIProcessing) -> Self {
        Self(operation: .workflow(.draftTrip(id, preferences, days, processing)))
    }

    static func findTrip(_ id: UUID, _ question: String) -> Self { Self(operation: .workflow(.findTrip(id, question))) }
    static func checklist(_ id: UUID, _ preferences: String?) -> Self {
        Self(operation: .workflow(.checklist(id, preferences)))
    }

    static func searchPlace(_ request: TripPlaceSearchRequest) -> Self { Self(operation: .workflow(.searchPlace(request))) }
    static func importBooking(_ request: TripBookingImportRequest) -> Self { Self(operation: .workflow(.importBooking(request))) }
    static func workspaceTool(_ id: UUID, _ tool: TripWorkspaceTool) -> Self {
        Self(operation: .workflow(.workspaceTool(id, tool)))
    }

    static func dayTool(_ id: UUID, _ dayID: UUID, _ tool: TripDayTool) -> Self {
        Self(operation: .workflow(.dayTool(id, dayID, tool)))
    }

    static func editDetail(_ identity: TripDetailIdentity) -> Self { Self(operation: .workflow(.editDetail(identity))) }
    static func newEvent(_ request: TripNewEventRequest) -> Self { Self(operation: .workflow(.newEvent(request))) }
}
