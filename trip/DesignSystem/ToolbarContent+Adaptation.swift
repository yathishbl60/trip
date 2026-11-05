import SwiftUI

extension ToolbarContent {
    /// Preserve readable titles and segmented controls when system bars move to a side.
    @ToolbarContentBuilder func horizontalToolbarItem() -> some ToolbarContent {
        #if os(iOS)
        axisBehavior(.horizontalOnly)
        #else
        self
        #endif
    }

    @ToolbarContentBuilder func prioritizedToolbarItem() -> some ToolbarContent {
        #if os(iOS)
        visibilityPriority(.high)
        #else
        self
        #endif
    }
}
