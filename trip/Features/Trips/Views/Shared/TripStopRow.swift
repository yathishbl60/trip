import TripLocalization
import TripDomain
import SwiftUI

struct TripStopRow: View {
    let stop: TripStop
    let controller: TripController
    var showsMapIndicator = true

    var body: some View {
        Button { controller.showOnMap(stop.place) } label: {
            HStack(spacing: AppTheme.Spacing.medium) {
                TripPlaceLabel(title: stop.place.name, subtitle: stop.place.category.annotationTitle,
                               symbol: stop.place.category.symbol, color: stop.place.category.color)
                if showsMapIndicator { Image(systemName: "map").foregroundStyle(AppTheme.accent).accessibilityHidden(true) }
            }
            .padding(.vertical, AppTheme.Spacing.tight).contentShape(.rect)
        }
        .buttonStyle(.plain).hoverEffect(.highlight)
        .accessibilityHint(TripText.showThisPlaceOnTheMap.resource)
        .contextMenu { actions }
    }

    @ViewBuilder private var actions: some View {
        Button(TripText.showOnMap.resource, systemImage: "map") { controller.showOnMap(stop.place) }
        if let url = stop.place.mapsURL {
            ShareLink(item: url, preview: SharePreview(stop.place.name))
        }
    }

}

#if DEBUG
#Preview("Saved stop", traits: .sizeThatFitsLayout) {
    TripStopRow(stop: TripStop(place: PreviewFixtures.hotel),
                controller: TripController(model: PreviewFixtures.tripPlanner())).padding()
}
#Preview("Long stop · dark", traits: .sizeThatFitsLayout) {
    TripStopRow(stop: TripStop(place: PreviewFixtures.longName),
                controller: TripController(model: PreviewFixtures.tripPlanner()))
        .padding().preferredColorScheme(.dark)
}
#Preview("Saved stop · full row, large text") {
    List {
        TripStopRow(stop: TripStop(place: PreviewFixtures.longName),
                    controller: TripController(model: PreviewFixtures.tripPlanner()))
    }.frame(width: 320).dynamicTypeSize(.accessibility2)
}
#endif
