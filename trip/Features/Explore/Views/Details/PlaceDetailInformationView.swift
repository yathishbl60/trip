import SwiftUI
import TripDomain

struct PlaceDetailInformationView: View {
    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(place.name).font(.title2.bold()).fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
                .textSelection(.enabled)
            Label {
                Text(place.category.annotationTitle).foregroundStyle(.secondary)
            } icon: {
                Image(systemName: place.category.symbol).foregroundStyle(place.category.color)
            }.font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

#if DEBUG
#Preview("Place identity", traits: .sizeThatFitsLayout) {
    PlaceDetailInformationView(place: PlaceDetailPreviewFixtures.live).padding()
}
#Preview("Place identity · accessibility", traits: .sizeThatFitsLayout) {
    PlaceDetailInformationView(place: PreviewFixtures.longName)
        .padding().dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
