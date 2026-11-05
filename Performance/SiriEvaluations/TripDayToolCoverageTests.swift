#if DEBUG && canImport(trip)
import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite("Trip day tools", .serialized)
struct TripDayToolCoverageTests {
    @Test("Every day tool opens the requested saved day", arguments: TripDayTool.allCases)
    func dayTools(_ tool: TripDayTool) throws {
        let model = PreviewFixtures.app()
        let plan = try #require(model.trips.library.trips.first)
        let day = try #require(plan.days.last)
        let revision = model.trips.library.revision
        model.request(.dayTool(plan.id, day.id, tool))
        #expect(model.trips.selectedTripID == plan.id)
        switch tool {
        case .schedule: #expect(model.trips.presentation.daySchedule?.dayID == day.id)
        case .planning: #expect(model.trips.presentation.planning?.day.id == day.id)
        case .weather: #expect(model.trips.presentation.weatherDestination?.dayID == day.id)
        case .addPlaces: #expect(model.trips.presentation.savedPlacePicker?.dayID == day.id)
        case .map: #expect(model.trips.presentation.detailRoute?.dayID == day.id)
        }
        #expect(model.trips.library.revision == revision)
    }

    @Test("Timezone review takes precedence over schedule editing")
    func timezoneReview() throws {
        var plan = TripPlan(title: "Review timezone")
        plan.timeZoneID = nil
        plan.localStartDate = nil
        let trips = PreviewTripServices.makeTrips([plan])
        let model = AppModel(explore: PreviewFixtures.explore(), trips: trips)
        model.request(.dayTool(plan.id, plan.days[0].id, .schedule))
        #expect(trips.presentation.editDraft?.tripID == plan.id)
        #expect(trips.presentation.daySchedule == nil)
    }
}
#endif
