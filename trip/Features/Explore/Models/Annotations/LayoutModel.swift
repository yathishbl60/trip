#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import Observation
import Foundation

@MainActor @Observable final class LayoutModel {
    var markers: [MarkerModel] = []
    var projectionRevision = 0
    @ObservationIgnored let scheduler = LayoutScheduler()
    @ObservationIgnored var cleanupTask: Task<Void, Never>?
    @ObservationIgnored var refinementTask: Task<Void, Never>?
    @ObservationIgnored var generation = 0
    @ObservationIgnored var candidates: [ProjectedPlace] = []
    @ObservationIgnored var projectionRetryTask: Task<Void, Never>?
    @ObservationIgnored var projectionAttempts = 0
    @ObservationIgnored var viewportTask: Task<Void, Never>?
    @ObservationIgnored private var cleanupGeneration = 0
    @ObservationIgnored private var indexed: [String: MarkerModel] = [:]
    let motion: MapMotion

    init(motion: MapMotion = .init()) { self.motion = motion }

    func invalidateProjection() {
        cancelPending()
        projectionRevision += 1
    }

    func cancelPending() {
        generation += 1
        scheduler.cancel()
        refinementTask?.cancel()
        refinementTask = nil
    }

    var history: [String: MarkerStyle] {
        markers.reduce(into: [:]) { if $1.hasAppeared || $1.isFading { $0[$1.id] = $1.style } }
    }

    var needsRefinement: Bool {
        markers.contains { $0.visibility == .retiring || $0.hasActiveReservation }
    }

    func apply(_ placements: [MarkerPlacement], scale: CGFloat, reduceMotion: Bool,
               retirementLimit: Int = MarkerLayoutPolicy().retirementLimit) {
        let previousIDs = Set(indexed.keys)
        let activeIDs = Set(placements.map { $0.place.id })
        for marker in markers where !activeIDs.contains(marker.id) { marker.retire() }
        for placement in placements {
            let marker = indexed[placement.place.id] ?? MarkerModel(placement: placement, scale: scale, motion: motion)
            marker.update(placement, scale: scale, reduceMotion: reduceMotion)
            indexed[marker.id] = marker
        }
        pruneRetired()
        trimRetired(to: reduceMotion ? 0 : max(0, retirementLimit))
        if previousIDs != Set(indexed.keys) { markers = indexed.values.sorted { $0.id < $1.id } }
        scheduleCleanup()
    }

    private func trimRetired(to limit: Int) {
        let now = ContinuousClock.now
        let retiring = indexed.values.filter { $0.visibility == .retiring }.sorted {
            let left = $0.hiddenAt ?? now, right = $1.hiddenAt ?? now
            return left == right ? $0.id < $1.id : left < right
        }
        for marker in retiring.prefix(max(0, retiring.count - limit)) { indexed.removeValue(forKey: marker.id) }
    }

    private func scheduleCleanup() {
        guard cleanupTask == nil, markers.contains(where: { $0.visibility == .retiring }) else { return }
        let generation = cleanupGeneration
        cleanupTask = Task {
            do {
                try await Task.sleep(for: motion.retirement)
                guard generation == cleanupGeneration else { return }
                pruneRetired()
                cleanupTask = nil
                scheduleCleanup()
            } catch { if generation == cleanupGeneration { cleanupTask = nil } }
        }
    }

    private func pruneRetired(immediately: Bool = false) {
        let ids = Set(markers.filter { $0.visibility == .retiring && (immediately || $0.canRemove) }.map(\.id))
        guard !ids.isEmpty else { return }
        for id in ids { indexed.removeValue(forKey: id) }
        markers.removeAll { ids.contains($0.id) }
    }

    func stop() {
        cancelPending()
        projectionReady()
        viewportTask?.cancel()
        cleanupGeneration += 1
        cleanupTask?.cancel()
        cleanupTask = nil
        pruneRetired(immediately: true)
    }
}
