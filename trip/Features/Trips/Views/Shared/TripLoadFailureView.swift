import TripLocalization
import SwiftUI

struct TripLoadFailureView: View {
    let error: String
    let controller: TripController

    var body: some View {
        ContentUnavailableView {
            Label(TripText.tripsUnavailable.resource, systemImage: "externaldrive.badge.exclamationmark")
        } description: {
            Text(error)
        } actions: {
            if controller.model.library.isLoading {
                ProgressView(TripText.loadingTrips.resource)
            } else {
                Button(TripText.tryAgain.resource) { Task { await controller.load() } }
                    .buttonStyle(TripButtonStyles.prominent)
                    .tint(AppTheme.accentFill)
            }
        }
    }
}

#if DEBUG
#Preview("Storage unavailable") {
    TripLoadFailureView(error: "Saved trips could not be opened. Your existing plans have not been changed.",
                        controller: TripController(model: PreviewFixtures.emptyTripPlanner()))
}
#Preview("Storage unavailable · accessibility") {
    TripLoadFailureView(error: "Saved trips could not be opened. Please try again.",
                        controller: TripController(model: PreviewFixtures.emptyTripPlanner()))
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Retrying saved trips · local state") {
    let model = PreviewFixtures.emptyTripPlanner()
    model.library.isLoading = true
    return TripLoadFailureView(error: "Saved trips could not be opened. Please try again.",
                               controller: TripController(model: model))
}
#endif
