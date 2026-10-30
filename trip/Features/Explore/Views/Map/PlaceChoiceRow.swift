import TripDomain
import SwiftUI

struct PlaceChoiceRow: View {
    let place: Place

    var body: some View {
        TripPlaceLabel(title: place.name, subtitle: place.address ?? place.category.annotationTitle,
                       symbol: place.category.symbol, color: place.category.color)
        .frame(maxWidth: .infinity, minHeight: AppTheme.controlTarget, alignment: .leading)
        .padding(.vertical, AppTheme.Spacing.tight)
        .contentShape(.rect)
    }
}

#if DEBUG
#Preview("Place row · native list") {
    List {
        PlaceChoiceRow(place: PreviewFixtures.hotel)
        PlaceChoiceRow(place: PlaceDetailPreviewFixtures.live)
    }
}
#Preview("Long name · accessibility, dark") {
    List { PlaceChoiceRow(place: PreviewFixtures.longName) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
