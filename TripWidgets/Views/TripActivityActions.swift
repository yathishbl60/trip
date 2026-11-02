import TripLocalization
#if os(iOS)
import AppIntents
import SwiftUI

struct TripActivityActions: View {
    let attributes: TripActivityAttributes
    let state: TripActivityAttributes.ContentState
    let presentation: TripActivityPresentation

    var body: some View {
        HStack(spacing: 8) {
            if let url = presentation.directionsURL {
                Link(destination: url) { Image(systemName: "arrow.triangle.turn.up.right.diamond") }
                    .accessibilityLabel(TripText.directionsToValueInMaps(state.nextStopName).resource)
            }
            if presentation.canVisit, let id = state.nextStopID {
                Button(intent: CompleteTripStopIntent(stopID: id, tripID: attributes.tripID, dayID: attributes.dayID)) {
                    Image(systemName: "checkmark").font(.headline)
                }.tint(WidgetTheme.accentFill).accessibilityLabel(TripText.markValueVisited(state.nextStopName).resource)
            } else if let url = TripSystemData.tripURL(attributes.tripID) {
                Link(destination: url) { Image(systemName: "arrow.up.forward.app") }.accessibilityLabel(TripText.openTrip2.resource)
            }
        }.buttonStyle(.borderedProminent).buttonBorderShape(.circle)
    }
}

#if DEBUG
#Preview("Activity actions · stale") {
    let attributes = TripActivityFixtures.attributes
    let state = TripActivityFixtures.active
    TripActivityActions(attributes: attributes, state: state,
                        presentation: TripActivityPresentation(attributes: attributes, state: state, isStale: true))
}
#Preview("Activity actions · directions") {
    let attributes = TripActivityFixtures.attributes
    let state = TripActivityFixtures.active
    TripActivityActions(attributes: attributes, state: state,
                        presentation: TripActivityPresentation(attributes: attributes, state: state, isStale: false))
}
#endif
#endif
