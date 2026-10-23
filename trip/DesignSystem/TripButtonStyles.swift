import SwiftUI

enum TripButtonStyles {
    static var regular: some PrimitiveButtonStyle {
        #if os(visionOS)
        BorderedButtonStyle()
        #else
        GlassButtonStyle()
        #endif
    }

    static var prominent: some PrimitiveButtonStyle {
        #if os(visionOS)
        BorderedProminentButtonStyle()
        #else
        GlassProminentButtonStyle()
        #endif
    }
}
