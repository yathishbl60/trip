import CoreGraphics
import MapEngine
import Observation
import TripDomain

@MainActor @Observable final class MapBrowseModel {
    private(set) var isPresented = false
    private(set) var revision = 0
    private(set) var items: [MapBrowseItem] = []
    private(set) var isRefreshing = false
    private(set) var hasLoaded = false
    private(set) var canResolveArea = true
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private var lastSample: CameraSample?
    @ObservationIgnored private var lastSize = CGSize.zero
    @ObservationIgnored private var needsRefresh = true

    func open() {
        revision += 1
        isPresented = true
        invalidate()
        isRefreshing = true
    }

    func close() {
        revision += 1
        isPresented = false
        invalidate()
    }

    func invalidate(clear: Bool = false) {
        generation += 1
        task?.cancel()
        task = nil
        lastSample = nil
        needsRefresh = true
        isRefreshing = false
        if clear { items = []; hasLoaded = false }
    }

    func unavailableArea() {
        guard isPresented, canResolveArea else { return }
        invalidate(clear: true)
        canResolveArea = false
    }

    func refresh(index: GeographicIndex, categories: Set<PlaceCategory>, region: MapCandidateRegion,
                 center: Coordinate, sample: CameraSample?, size: CGSize) {
        guard isPresented, needsRefresh || lastSample != sample || lastSize != size else { return }
        invalidate()
        needsRefresh = false
        canResolveArea = true
        lastSample = sample
        lastSize = size
        let token = generation
        isRefreshing = true
        task = Task { [weak self] in
            guard let items = try? await MapBrowseItem.load(index: index, region: region, categories: categories, center: center),
                  let self, !Task.isCancelled, token == generation else { return }
            self.items = items
            hasLoaded = true
            isRefreshing = false
            task = nil
        }
    }
}
