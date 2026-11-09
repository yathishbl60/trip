import Observation
import TripDomain
import TripLocalization

@MainActor @Observable final class PlaceHistoryModel {
    private(set) var history = RecentPlaceHistory()
    private(set) var error: String?
    @ObservationIgnored private let store: any RecentPlaceStoring
    @ObservationIgnored private var revision = 0
    @ObservationIgnored private var hasLoaded = false
    @ObservationIgnored private var loadTask: Task<RecentPlaceHistory?, Never>?

    init(store: any RecentPlaceStoring = MemoryRecentPlaceStore()) { self.store = store }

    func load() async {
        guard !hasLoaded else { return }
        if loadTask == nil { loadTask = Task { try? await store.load() } }
        let loaded = await loadTask?.value
        guard !hasLoaded else { return }
        hasLoaded = true
        loadTask = nil
        if revision == 0, let loaded { history = loaded }
    }

    func record(_ entry: RecentPlaceEntry) {
        history.record(entry)
        persist()
    }

    func clear() {
        history = RecentPlaceHistory()
        persist()
    }

    func persist() {
        revision += 1
        let token = revision
        let snapshot = history
        error = nil
        Task { [weak self, store] in
            do { try await store.save(snapshot, revision: token) }
            catch {
                guard let self, revision == token else { return }
                self.error = TripText.couldNotUpdateRecentHistory.text
            }
        }
    }
}
