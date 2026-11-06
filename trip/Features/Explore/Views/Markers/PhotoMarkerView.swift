#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import SwiftUI

/// One hierarchy expands from a photo token into a readable place card.
struct PhotoMarkerView: View, Equatable {
    let place: Place
    let style: MarkerStyle
    var isSelected = false
    var includesPhoto = true
    var includesLabel = true

    var body: some View {
        HStack(spacing: style.contentSpacing) {
            MarkerArtworkView(place: place, style: style, includesPhoto: includesPhoto)
            caption
                .frame(width: style.captionWidth, height: style.contentHeight, alignment: .leading)
                .opacity(style.labelOpacity)
                .clipped()
        }
        .padding(style.contentInset)
        .frame(width: style.size.width, height: style.size.height)
        .background { MarkerSurfaceView(category: place.category, style: style, isSelected: isSelected) }
    }

    @ViewBuilder private var caption: some View {
        if includesLabel {
            MarkerCaptionView(place: place, style: style).transition(.opacity)
        }
    }
}

#if DEBUG
#Preview("Progressive place chips", traits: .sizeThatFitsLayout) {
    VStack(alignment: .leading, spacing: 24) {
        ForEach(MarkerStyle.allCases, id: \.self) { style in
            PhotoMarkerView(place: PreviewFixtures.hotel, style: style)
        }
    }
    .padding(28)
}
#Preview("Selected card · dark", traits: .sizeThatFitsLayout) {
    PhotoMarkerView(place: PreviewFixtures.longName, style: .card, isSelected: true)
        .padding(28).preferredColorScheme(.dark)
}
#Preview("Unrated card", traits: .sizeThatFitsLayout) {
    PhotoMarkerView(place: PreviewFixtures.unrated, style: .card).padding(28)
}
#Preview("Saved sample · missing photo uses category artwork") {
    PhotoMarkerView(place: PreviewFixtures.hotel, style: .card)
        .padding().preferredColorScheme(.dark)
}
#Preview("Long name · full card footprint, accessibility scale") {
    PlaceMarkerView(place: PreviewFixtures.longName, style: .card, scale: 1.5)
        .padding().frame(width: 320).preferredColorScheme(.dark)
}
#endif
