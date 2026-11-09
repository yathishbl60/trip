import TripDomain
import MapEngine
import MapKit
import SwiftUI

extension ExploreModel {
    func cameraChanged(_ context: MapCameraUpdateContext, proxy: MapProxy) {
        let hadSample = camera.sample != nil
        let changed = camera.update(context)
        guard !isSuspended, changed else { return }
        if !hadSample {
            refreshLayout(using: proxy, force: true)
            return
        }
        if !camera.isMoving {
            browse.invalidate()
            catalog.cancelScheduledSearch()
            layout.cancelPending()
        }
        camera.isMoving = true
        layout.refinementTask?.cancel()
        refreshLayout(using: proxy, force: false)
    }

    func cameraSettled(_ context: MapCameraUpdateContext, proxy: MapProxy) {
        camera.update(context)
        guard !isSuspended else { return }
        camera.updateNavigationState(context.camera)
        camera.isMoving = false
        if revealSelection(using: proxy) { return }
        camera.restoration.record(context.camera)
        refreshLayout(using: proxy, force: true)
        scheduleSearch()
    }

    func requestProjection() {
        guard !isSuspended else { return }
        layout.invalidateProjection()
    }

    func refreshLayout(using proxy: MapProxy, force: Bool) {
        guard !isSuspended, camera.size.width > 0, camera.size.height > 0 else { return }
        guard force || camera.needsLayout else { return }
        let now = ContinuousClock.now
        guard force || camera.lastLayoutTime.duration(to: now) > configuration.layout.interval else { return }
        camera.lastLayoutTime = now
        camera.lastLayoutSample = camera.sample
        guard let projection = captureProjection(using: proxy) else {
            camera.groundScale = nil
            layout.retryProjection()
            return
        }
        layout.projectionReady()
        if camera.zoom != projection.zoom { camera.zoom = projection.zoom }
        refreshBrowse(projection)
        guard !catalog.places.isEmpty || !layout.markers.isEmpty || selectedPlace != nil else { return }
        submitLayout(projection)
    }

    func submitLayout(_ projection: MapProjection) {
        layout.generation += 1
        let request = makeLayoutRequest(projection, isSettled: !camera.isMoving)
        layout.scheduler.submit(request) { [weak self] request, placements in
            self?.apply(placements, for: request, projection: projection)
        }
    }

    private func apply(_ placements: [MarkerPlacement], for request: LayoutRequest, projection: MapProjection) {
        guard request.generation == layout.generation else { return }
        layout.candidates = projection.candidates
        MapPerformance.measure("Apply map markers") {
            layout.apply(placements, scale: request.scale, reduceMotion: camera.reduceMotion,
                         retirementLimit: request.policy.retirementLimit)
        }
        layout.updateSelection(selectedPlace?.id)
        if request.isSettled { scheduleRefinement(projection, generation: request.generation) }
    }
}
