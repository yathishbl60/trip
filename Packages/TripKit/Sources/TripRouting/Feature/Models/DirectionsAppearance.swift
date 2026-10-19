#if os(iOS) || os(visionOS)
import SwiftUI

/// Host-customizable colors; routes remain distinct from the app's action tint.
public nonisolated struct DirectionsAppearance: Sendable {
    public var route: Color
    public var calloutFill: Color
    public var calloutText: Color
    public var actionTint: Color

    public init(route: Color = .blue, calloutFill: Color = Color(red: 0, green: 0.32, blue: 0.65),
                calloutText: Color = .white, actionTint: Color = Color(red: 0, green: 0.32, blue: 0.65)) {
        self.route = route
        self.calloutFill = calloutFill
        self.calloutText = calloutText
        self.actionTint = actionTint
    }
}
#endif
