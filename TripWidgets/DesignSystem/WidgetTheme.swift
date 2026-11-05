import SwiftUI

/// Uses the same asset catalog as the host, including increased-contrast variants.
enum WidgetTheme {
    static let accent = Color("AccentColor")
    static let accentFill = Color("AccentFill")

    // Same spacing scale as the host; compact is reserved for constrained system surfaces.
    enum Spacing {
        static let compact: CGFloat = 2
        static let tight: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
    }
}
