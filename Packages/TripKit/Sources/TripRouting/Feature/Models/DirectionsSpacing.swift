#if os(iOS) || os(visionOS)
import SwiftUI

/// Local presentation metrics keep the routing package independent of its host app.
enum DirectionsSpacing {
    static let tight: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
}
#endif
