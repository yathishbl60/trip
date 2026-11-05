import Foundation
import TripDomain

extension AppRuntime {
    static func openSection(_ section: TripSection, tripID: UUID) async throws {
        _ = try await navigationTrip(tripID)
        AppLaunchModel.shared.open(.section(tripID, section))
    }

    static func openWorkspaceTool(_ tool: TripWorkspaceTool, tripID: UUID) async throws {
        _ = try await navigationTrip(tripID)
        if tool != .tripDetails, !AppTripServices.systemActions.supportsCalendarReminders {
            throw TripSystemActionError.unavailable
        }
        AppLaunchModel.shared.open(.workspaceTool(tripID, tool))
    }

    static func openDayTool(_ tool: TripDayTool, tripID: UUID, number: Int) async throws {
        let plan = try await navigationTrip(tripID)
        guard let day = plan.days.first(where: { $0.number == number }) else { throw TripIntentError.missingDay }
        AppLaunchModel.shared.open(.dayTool(tripID, day.id, tool))
    }

    static func editDetail(_ identity: TripDetailIdentity) async throws {
        let plan = try await navigationTrip(identity.tripID)
        guard identity.resolve(in: TripSurfacePlan(plan)) != nil else { throw TripDetailIntentError.missingDetail }
        AppLaunchModel.shared.open(.editDetail(identity))
    }

    private static func navigationTrip(_ id: UUID) async throws -> TripPlan {
        let plan = try await trip(id)
        guard activeScene?.trips.hasEditingSession != true else { throw TripDetailIntentError.editing }
        return plan
    }
}
