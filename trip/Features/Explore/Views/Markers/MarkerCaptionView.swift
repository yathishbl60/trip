#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import SwiftUI

struct MarkerCaptionView: View {
    let place: Place
    let style: MarkerStyle

    var body: some View {
        VStack(alignment: .leading, spacing: MarkerStyle.captionSpacing) {
            title
            AnnotationRatingView(place: place, showsReviews: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var title: some View {
        Text(place.name)
            .font(.system(size: style.titleSize, weight: .semibold))
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .lineLimit(style.titleLines)
            .allowsTightening(true)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, minHeight: MarkerStyle.captionTitleHeight,
                   maxHeight: MarkerStyle.captionTitleHeight, alignment: .leading)
    }
}

#if DEBUG
#Preview("Readable place labels", traits: .sizeThatFitsLayout) {
    VStack(spacing: 24) {
        MarkerCaptionView(place: PreviewFixtures.hotel, style: .card)
        MarkerCaptionView(place: PreviewFixtures.longName, style: .card)
        MarkerCaptionView(place: PreviewFixtures.unrated, style: .card)
    }
    .frame(width: MarkerStyle.card.captionWidth).padding(24)
}
#Preview("Dark label", traits: .sizeThatFitsLayout) {
    MarkerCaptionView(place: PreviewFixtures.hotel, style: .card)
        .frame(width: MarkerStyle.card.captionWidth).padding(24).preferredColorScheme(.dark)
}
#Preview("Complex scripts · fixed card caption") {
    VStack(spacing: 24) {
        ForEach(["พิพิธภัณฑ์และหอศิลป์กรุงเทพ", "कला और इतिहास संग्रहालय", "ಕಲೆ ಮತ್ತು ಇತಿಹಾಸ ಸಂಗ್ರಹಾಲಯ"], id: \.self) { name in
            let place = Place(id: name, name: name, coordinate: .bangkok, category: .museum,
                              importance: 1, rating: nil, reviews: nil, isLive: true)
            MarkerCaptionView(place: place, style: .card)
                .frame(width: MarkerStyle.card.captionWidth, height: MarkerStyle.card.contentHeight)
        }
    }.padding().preferredColorScheme(.dark)
}
#endif
