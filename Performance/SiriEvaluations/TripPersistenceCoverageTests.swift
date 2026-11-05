#if DEBUG && canImport(trip)
import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite("Trip persistence recovery", .serialized)
struct TripPersistenceCoverageTests {
    @Test("Failed saves retain edits and publish only after retry")
    func failedSaveRetry() async throws {
        let plan = TripPlan(title: "Original")
        let store = TripCoverageStore([plan])
        let library = TripLibraryModel(store: store, loadedTrips: [plan])
        var published = 0
        library.onSaved = { _ in published += 1 }
        library.update(plan.id) { $0.title = "Updated"; return true }
        await library.flush()
        #expect(library.saveError != nil)
        #expect(library.trip(plan.id)?.title == "Updated")
        #expect(published == 0)
        await store.allowSaving()
        await library.flush()
        #expect(library.saveError == nil)
        #expect(published == 1)
        #expect(await store.load().first?.title == "Updated")
    }

    @Test("An obsolete load cannot replace newer library content")
    func staleLoad() {
        let old = TripPlan(title: "Stored")
        let model = TripLibraryModel(store: TripCoverageStore([old]), loadedTrips: [old])
        let revision = model.revision
        let added = TripPlan(title: "Newer edit")
        model.insert(added)
        model.acceptLoaded([old], startingRevision: revision)
        #expect(model.trip(added.id) != nil)
        #expect(model.trips.count == 2)
    }

    @Test("Flushing a clean library does not publish or save twice")
    func cleanFlush() async {
        let plan = TripPlan(title: "Original")
        let store = TripCoverageStore([plan])
        await store.allowSaving()
        let model = TripLibraryModel(store: store, loadedTrips: [plan])
        model.update(plan.id) { $0.title = "Updated"; return true }
        await model.flush()
        await model.flush()
        #expect(await store.saveCount == 1)
    }
}

private actor TripCoverageStore: TripStoring {
    private var plans: [TripPlan]
    private var fails = true
    private(set) var saveCount = 0
    private enum Failure: Error { case simulatedSave }

    init(_ plans: [TripPlan]) { self.plans = plans }
    func load() -> [TripPlan] { plans }
    func allowSaving() { fails = false }

    func save(_ plans: [TripPlan], revision: Int, changedIDs: Set<UUID>?) throws {
        if fails { throw Failure.simulatedSave }
        self.plans = plans
        saveCount += 1
    }
}
#endif
