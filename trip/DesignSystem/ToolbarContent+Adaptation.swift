import SwiftUI

extension ToolbarContent {
    /// Preserve readable titles and segmented controls when system bars move to a side.
    @ToolbarContentBuilder func horizontalToolbarItem() -> some ToolbarContent {
        #if os(iOS)
        if #available(iOS 27.1, *) { axisBehavior(.horizontalOnly) }
        else { self }
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
