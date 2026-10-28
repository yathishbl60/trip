import Observation
import CoreGraphics

@MainActor @Observable final class GalleryFilmstripModel {
    #if os(visionOS)
    static let itemWidth: CGFloat = 60
    #else
    static let itemWidth: CGFloat = 44
    #endif
    var position: String?
    private(set) var isScrubbing = false

    func follow(_ id: String?) {
        guard !isScrubbing else { return }
        position = id
    }

    func setScrubbing(_ scrubbing: Bool) { isScrubbing = scrubbing }
}
