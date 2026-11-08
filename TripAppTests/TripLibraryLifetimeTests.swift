import Foundation
import Testing
import TripDomain
@testable import trip

@MainActor @Suite(.timeLimit(.minutes(1))) struct TripLibraryLifetimeTests {
    @Test func onlyTheLatestSuspendedSavePublishes() async throws {
        let plan = TripPlan(title: "Original"), store = ControlledTripStore([])
        let library = TripLibraryModel(store: store, loadedTrips: [plan])
        var published: [String] = []
        library.onSaved = { published.append($0[0].title) }
        let first = save("First", in: library, tripID: plan.id)
        let firstRevision = library.revision
        await store.waitForSave(firstRevision)
        let second = save("Latest", in: library, tripID: plan.id)
        let latestRevision = library.revision
        await store.waitForSave(latestRevision)
        await store.finish(latestRevision)
        await second.value
        await store.finish(firstRevision)
        await first.value
        #expect(published == ["Latest"] && library.changedTrips.isEmpty)
        #expect(library.trip(plan.id)?.title == "Latest" && library.saveError == nil)
        #expect(try await store.load().first?.title == "Latest")
    }

    @Test func aFailedSaveRetainsChangesUntilSuccessfulRetry() async {
        let plan = TripPlan(title: "Original"), store = ControlledTripStore([])
        let library = TripLibraryModel(store: store, loadedTrips: [plan])
        var publications = 0
        library.onSaved = { _ in publications += 1 }
        let failed = save("Pending", in: library, tripID: plan.id)
        let revision = library.revision
        await store.waitForSave(revision)
        await store.finish(revision, failing: true)
        await failed.value
        #expect(library.saveError != nil && library.changedTrips.contains(plan.id) && publications == 0)
        let retry = Task { await library.flush() }
        await store.waitForSave(revision)
        await store.finish(revision)
        await retry.value
        #expect(library.saveError == nil && library.changedTrips.isEmpty && publications == 1)
        #expect(library.trip(plan.id)?.title == "Pending")
    }

    @Test func anObsoleteSaveFailureCannotReplaceANewerSuccess() async {
        let plan = TripPlan(title: "Original"), store = ControlledTripStore([])
        let library = TripLibraryModel(store: store, loadedTrips: [plan])
        let first = save("First", in: library, tripID: plan.id)
        let firstRevision = library.revision
        await store.waitForSave(firstRevision)
        let second = save("Latest", in: library, tripID: plan.id)
        let latestRevision = library.revision
        await store.waitForSave(latestRevision)
        await store.finish(latestRevision)
        await second.value
        await store.finish(firstRevision, failing: true)
        await first.value
        #expect(library.saveError == nil && library.changedTrips.isEmpty)
        #expect(library.trip(plan.id)?.title == "Latest")
    }

    private func save(_ title: String, in library: TripLibraryModel, tripID: UUID) -> Task<Void, Never> {
        library.update(tripID) { $0.title = title; return true }
        library.saveTask?.cancel()
        return Task { await library.flush() }
    }
}
