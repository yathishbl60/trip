import SwiftUI

struct TripFeedbackView: View {
    let model: TripFeedbackModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if let message = model.message {
                Label { Text(message) } icon: { confirmationSymbol }
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .tripGlassSurface().padding(.horizontal, 24)
                    .transition(.opacity)
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .animation(reduceMotion ? nil : .smooth(duration: 0.2), value: model.message)
        .sensoryFeedback(.success, trigger: model.revision)
        .allowsHitTesting(false)
    }

    private var confirmationSymbol: some View {
        Image(systemName: "checkmark.circle.fill")
            .symbolRenderingMode(.palette)
            .foregroundStyle(.primary, AppTheme.accent.opacity(0.2))
            .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Added to trip", traits: .sizeThatFitsLayout) {
    let model = TripFeedbackModel()
    model.message = "Added to Bangkok weekend"
    return TripFeedbackView(model: model).padding()
}
#Preview("Long confirmation · dark", traits: .sizeThatFitsLayout) {
    let model = TripFeedbackModel()
    model.message = "Added to a wonderful long weekend exploring Bangkok"
    return TripFeedbackView(model: model).frame(width: 320).padding().preferredColorScheme(.dark)
}
#endif
