import SwiftUI

struct TripFeedbackView: View {
    let model: TripFeedbackModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if let message = model.message {
                Label { Text(message) } icon: { confirmationSymbol }
                    .font(.subheadline.weight(.medium)).fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, AppTheme.Spacing.medium).padding(.vertical, AppTheme.Spacing.small)
                    .tripGlassSurface().padding(.horizontal, AppTheme.Spacing.edge)
                    .transition(.opacity)
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .animation(AppTheme.Motion.feedback(reduceMotion: reduceMotion), value: model.message)
        .sensoryFeedback(.success, trigger: model.revision)
        .allowsHitTesting(false)
    }

    private var confirmationSymbol: some View {
        TripSuccessSymbol(revision: model.revision)
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
