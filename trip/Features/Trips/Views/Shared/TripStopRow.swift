import TripLocalization
import TripDomain
import SwiftUI

struct TripStopRow: View {
    let stop: TripStop
    var showsMapIndicator = true
    let onShowPlace: () -> Void

    var body: some View {
        Button(action: onShowPlace) {
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
        Button(TripText.showOnMap.resource, systemImage: "map", action: onShowPlace)
        if let url = stop.place.mapsURL {
            ShareLink(item: url, preview: SharePreview(stop.place.name))
        }
    }

}

#if DEBUG
#Preview("Saved stop", traits: .sizeThatFitsLayout) {
    TripStopRow(stop: TripStop(place: PreviewFixtures.hotel), onShowPlace: {}).padding()
}
#Preview("Long stop · dark", traits: .sizeThatFitsLayout) {
    TripStopRow(stop: TripStop(place: PreviewFixtures.longName), onShowPlace: {})
        .padding().preferredColorScheme(.dark)
}
#Preview("Saved stop · full row, large text") {
    List {
        TripStopRow(stop: TripStop(place: PreviewFixtures.longName), onShowPlace: {})
    }.frame(width: 320).dynamicTypeSize(.accessibility2)
}
#endif
