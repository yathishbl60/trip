import SwiftUI

struct TripGlassSurface: ViewModifier {
    func body(content: Content) -> some View {
        #if os(visionOS)
        content.glassBackgroundEffect(in: .capsule)
        #else
        content.glassEffect()
        #endif
    }
}

extension View {
    func tripGlassSurface() -> some View { modifier(TripGlassSurface()) }
}

#Preview("Native glass surface", traits: .sizeThatFitsLayout) {
    Label("Saved to your trip", systemImage: "checkmark")
        .padding().tripGlassSurface()
}
