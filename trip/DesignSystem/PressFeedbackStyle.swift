import SwiftUI

struct PressFeedbackStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.72 : 1)
            .animation(AppTheme.Motion.press(reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}

#Preview("Press feedback", traits: .sizeThatFitsLayout) {
    Button("Press and release", systemImage: "line.3.horizontal.decrease") { }
        .padding().background(.regularMaterial, in: .capsule)
        .buttonStyle(PressFeedbackStyle()).padding()
}
