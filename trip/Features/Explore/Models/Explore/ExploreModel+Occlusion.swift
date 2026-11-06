import CoreGraphics

extension ExploreModel {
    /// Geometry is global; only value rectangles cross into the layout actor.
    var chromeExclusions: [CGRect] {
        let overlays = camera.reservedFrames + [MapViewportPolicy.sheetExclusion(camera.sheetFrame), camera.noticeFrame]
        return MapViewportOcclusion.exclusions(mapFrame: camera.frame, contentFrame: camera.contentFrame,
                                               overlays: overlays)
    }
}
