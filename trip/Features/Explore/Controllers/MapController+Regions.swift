import CoreGraphics

extension MapController {
    func reservedRegionsChanged(_ frames: [CGRect]) {
        guard model.camera.reservedFrames != frames else { return }
        model.camera.reservedFrames = frames
        model.requestProjection()
        model.selection.viewportChanged()
        model.directionsViewportChanged()
    }
}
