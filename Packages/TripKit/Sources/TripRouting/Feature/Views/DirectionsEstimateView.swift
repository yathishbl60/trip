#if !TRIP_STANDALONE
import TripLocalization
#endif
#if os(iOS) || os(visionOS)
import SwiftUI

struct DirectionsEstimateView: View {
    let estimate: DirectionsEstimate
    let routeLabel: String?
    var hasTolls = false
    var isTransit = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(estimate.durationText).font(.title.bold()).contentTransition(.numericText())
            Text(TripText.valueEtaValue(estimate.arrivalText, estimate.distanceText).resource)
                .font(.subheadline).foregroundStyle(.secondary)
            if let routeLabel { Text(routeLabel).font(.subheadline).foregroundStyle(.secondary) }
            if hasTolls {
                Label(TripText.tolls.resource, systemImage: "dollarsign.circle.fill")
                    .font(.subheadline).foregroundStyle(.secondary).labelStyle(.titleAndIcon)
            }
            if isTransit { Text(TripText.transitEstimate.resource).font(.subheadline).foregroundStyle(.secondary) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
#Preview("Screenshot regression · toll route, local") {
    let model = DirectionsPreviewFixtures.tollRoutes()
    if let estimate = model.estimate {
        List {
            DirectionsEstimateView(estimate: estimate, routeLabel: "Fastest", hasTolls: true)
        }.frame(width: 393).preferredColorScheme(.dark)
    }
}
#Preview("Route estimate · narrow, accessibility, local") {
    let model = DirectionsPreviewFixtures.tollRoutes()
    if let estimate = model.estimate {
        List {
            DirectionsEstimateView(estimate: estimate, routeLabel: "Suggested route along the river", hasTolls: true)
        }.frame(width: 320).dynamicTypeSize(.accessibility2)
    }
}
#endif
#endif
