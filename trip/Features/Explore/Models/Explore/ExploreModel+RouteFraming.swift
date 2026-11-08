import TripRouting
import SwiftUI
import MapEngine

extension ExploreModel {
    func directionsFrameChanged(_ frame: CGRect) {
        guard directions.isPresented, camera.recordPanelFrame(frame) else { return }
        if !isSuspended { layout.viewportSettled() }
        directionsViewportChanged()
    }

    func directionsViewportChanged() {
        guard directions.requestRouteFit() else { return }
        scheduleDirectionsFit()
    }

    /// Wait for the sheet to settle, coalescing route responses and detent changes.
    func scheduleDirectionsFit() {
        directions.scheduleRouteFit(isActive: { [weak self] in self?.isActive == true },
                                    fit: { [weak self] in self?.fitDirections() })
    }
}
