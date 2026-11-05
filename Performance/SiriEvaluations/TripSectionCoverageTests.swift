#if DEBUG && canImport(trip)
import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite("Trip sections", .serialized)
struct TripSectionCoverageTests {
    @Test("Every section retains trip identity", arguments: TripSection.allCases)
    func sections(_ section: TripSection) throws {
        let model = PreviewFixtures.app()
        let id = try #require(model.trips.library.trips.first?.id)
        model.request(.section(id, section))
        #expect(model.navigation.tab == .trips)
        #expect(model.trips.selectedTripID == id)
        #expect(model.trips.presentation.detailRoute?.destination == section.destination)
    }

    @Test("Repeated details handoffs preserve search and filters")
    func repeatedSearch() throws {
        let model = PreviewFixtures.app()
        let id = try #require(model.trips.library.trips.first?.id)
        model.request(.section(id, .details))
        model.trips.lookup.setSearchText("Bangkok")
        model.trips.lookup.choose(.places)
        model.trips.lookup.chooseDay(1)
        model.request(.section(id, .details))
        #expect(model.trips.lookup.searchText == "Bangkok")
        #expect(model.trips.lookup.query.category == .places)
        #expect(model.trips.lookup.query.dayNumber == 1)
    }

    @Test("Missing day handoffs retain the visible section")
    func missingDay() throws {
        let model = PreviewFixtures.app()
        let id = try #require(model.trips.library.trips.first?.id)
        model.request(.section(id, .today))
        model.request(.dayTool(id, UUID(), .map))
        #expect(model.trips.presentation.detailRoute?.destination == .today)
        #expect(model.navigation.notice != nil)
    }

    @Test("Deleted detail handoffs preserve the current view")
    func missingDetail() throws {
        let model = PreviewFixtures.app()
        let id = try #require(model.trips.library.trips.first?.id)
        model.request(.section(id, .collections))
        model.request(.editDetail(TripDetailIdentity(tripID: id, itemID: UUID())))
        #expect(model.trips.presentation.detailRoute?.destination == .collections)
        #expect(model.trips.presentation.eventDraft == nil)
        #expect(model.trips.presentation.stopTiming == nil)
        #expect(model.navigation.notice != nil)
    }

    @Test("Export reviews preserve navigation and do not save", arguments: [TripWorkspaceTool.calendar, .reminders])
    func exportReview(_ tool: TripWorkspaceTool) throws {
        let model = PreviewFixtures.app()
        let id = try #require(model.trips.library.trips.first?.id)
        let revision = model.trips.library.revision
        model.request(.section(id, .checklist))
        model.request(.workspaceTool(id, tool))
        #expect(model.trips.presentation.detailRoute?.destination == .checklist)
        #expect(model.trips.systemActions.presentation?.tripID == id)
        #expect(model.trips.systemActions.presentation?.kind == (tool == .calendar ? .calendar : .reminders))
        #expect(!model.trips.systemActions.isWorking)
        #expect(model.trips.library.revision == revision)
    }
}
#endif
