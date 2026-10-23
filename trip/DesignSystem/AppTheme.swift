import SwiftUI

enum AppTheme {
    static let accent = Color("AccentColor")
    static let accentFill = Color("AccentFill")
    static let onAccentFill = Color.white
    static let rating = Color("RatingColor")
    static let cornerRadius: CGFloat = 24
    static let spacing = Spacing.edge
    static var controlTarget: CGFloat {
        #if os(visionOS)
        60
        #else
        44
        #endif
    }

    enum Spacing {
        static let tight: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let edge: CGFloat = 20
    }
}
