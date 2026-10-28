import CoreGraphics
import SwiftUI

nonisolated struct GalleryGridViewport: Equatable {
    var offset: CGFloat = 0
    var height: CGFloat = 0
    var contentHeight: CGFloat = 0

    init() {}

    init(_ geometry: ScrollGeometry) {
        offset = geometry.contentOffset.y + geometry.contentInsets.top
        height = max(0, geometry.containerSize.height - geometry.contentInsets.top - geometry.contentInsets.bottom)
        contentHeight = geometry.contentSize.height
    }
}
