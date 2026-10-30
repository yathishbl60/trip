#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import SwiftUI

struct MarkerCaptionView: View {
    let place: Place
    let style: MarkerStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
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
            .minimumScaleFactor(0.78)
            .frame(maxWidth: .infinity, minHeight: 32, maxHeight: 32, alignment: .leading)
    }
}

#if DEBUG
#Preview("Readable place labels", traits: .sizeThatFitsLayout) {
    VStack(spacing: 24) {
        MarkerCaptionView(place: PreviewFixtures.hotel, style: .card)
        MarkerCaptionView(place: PreviewFixtures.longName, style: .card)
        MarkerCaptionView(place: PreviewFixtures.unrated, style: .card)
    }
    .frame(width: 104).padding(24)
}
#Preview("Dark label", traits: .sizeThatFitsLayout) {
    MarkerCaptionView(place: PreviewFixtures.hotel, style: .card)
        .frame(width: 104).padding(24).preferredColorScheme(.dark)
}
#endif
