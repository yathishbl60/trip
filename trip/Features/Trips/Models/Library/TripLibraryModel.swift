import TripDomain
import Observation
import Foundation

/// Owns durable snapshots and the lifecycle of one revisioned store session.
@MainActor @Observable final class TripLibraryModel {
    private(set) var trips: [TripPlan]
    private(set) var savedPlaceIndex: TripSavedPlaceIndex
    private(set) var savedMapGroups: [TripSavedPlaceGroup]
    private(set) var isReady: Bool
    var loadError: String?
    var saveError: String?
    var isLoading = false
    @ObservationIgnored let store: any TripStoring
    @ObservationIgnored var revision = 0
    @ObservationIgnored var loadTask: Task<Void, Never>?
    @ObservationIgnored var saveTask: Task<Void, Never>?
    @ObservationIgnored var changedTrips: Set<UUID> = []
    @ObservationIgnored var needsFullSave = false
    @ObservationIgnored var onSaved: @MainActor ([TripPlan]) async -> Void = { _ in }

    init(store: any TripStoring, loadedTrips: [TripPlan]? = nil) {
        self.store = store
        trips = loadedTrips ?? []
        let index = TripSavedPlaceIndex(loadedTrips ?? [])
        savedPlaceIndex = index
        savedMapGroups = index.groups
        isReady = loadedTrips != nil
    }

    func acceptLoaded(_ plans: [TripPlan], startingRevision: Int) {
        if revision == startingRevision {
            trips = plans
            savedPlaceIndex = TripSavedPlaceIndex(plans)
            savedMapGroups = savedPlaceIndex.groups
        }
        loadError = nil
        isReady = true
    }

    @discardableResult func insert(_ plan: TripPlan) -> Bool {
        guard isReady, canCreate, trip(plan.id) == nil else { return false }
        trips.insert(plan, at: 0)
        savedPlaceIndex.replace(plan)
        savedMapGroups = savedPlaceIndex.groups
        persist(changed: plan.id)
        return true
    }

    @discardableResult func update(_ id: UUID, edit: (inout TripPlan) -> Bool) -> Bool {
        guard isReady, let index = trips.firstIndex(where: { $0.id == id }) else { return false }
        var plan = trips[index]
        guard edit(&plan), plan.id == id else { return false }
        trips[index] = plan
        savedPlaceIndex.replace(plan)
        savedMapGroups = savedPlaceIndex.groups
        persist(changed: id)
        return true
    }

    func remove(_ id: UUID) {
        guard isReady, trips.contains(where: { $0.id == id }) else { return }
        trips.removeAll { $0.id == id }
        savedPlaceIndex.remove(id)
        savedMapGroups = savedPlaceIndex.groups
        persist()
    }

    func trip(_ id: UUID) -> TripPlan? { trips.first { $0.id == id } }
    var canCreate: Bool { trips.count < TripLimits.trips }
}
