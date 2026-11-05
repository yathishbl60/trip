import TripLocalization
import SwiftUI

struct TripPersistenceStatusView: View {
    let controller: TripController

    var body: some View {
        if let error = controller.model.library.saveError {
            Button(action: controller.retrySave) {
                Label(TripText.valueTryAgain(error).resource, systemImage: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90")
                    .font(.caption).multilineTextAlignment(.leading)
            }
            .buttonStyle(TripButtonStyles.regular).padding(AppTheme.Spacing.medium)
        }
    }
}

#if DEBUG
#Preview("Unsaved changes", traits: .sizeThatFitsLayout) {
    let model = PreviewFixtures.tripPlanner()
    model.library.saveError = "Your latest changes weren’t saved."
    return TripPersistenceStatusView(controller: TripController(model: model)).frame(width: 360)
}
#Preview("Unsaved changes · dark", traits: .sizeThatFitsLayout) {
    let model = PreviewFixtures.tripPlanner()
    model.library.saveError = "Your latest changes weren’t saved."
    return TripPersistenceStatusView(controller: TripController(model: model))
        .frame(width: 320).dynamicTypeSize(.accessibility1).preferredColorScheme(.dark)
}
#endif
