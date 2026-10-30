#if !TRIP_STANDALONE
import TripDomain
#endif
import SwiftUI

struct AnnotationRatingView: View {
    let place: Place
    var showsReviews = false

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: place.annotationRatingSymbol)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(place.rating == nil ? Color.secondary : AppTheme.rating)
            Text(place.annotationRatingText)
                .font(.system(size: 11, weight: .semibold)).foregroundStyle(.primary)
            if showsReviews, place.rating != nil {
                Text(place.reviewText).font(.system(size: 10)).foregroundStyle(.secondary)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .frame(height: 14)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview("Rating and missing rating", traits: .sizeThatFitsLayout) {
    VStack(alignment: .leading, spacing: 16) {
        AnnotationRatingView(place: PreviewFixtures.hotel)
        AnnotationRatingView(place: PreviewFixtures.hotel, showsReviews: true)
        AnnotationRatingView(place: PreviewFixtures.unrated)
    }
    .padding(24)
}
#Preview("Rating · dark", traits: .sizeThatFitsLayout) {
    AnnotationRatingView(place: PreviewFixtures.hotel, showsReviews: true)
        .padding(24).preferredColorScheme(.dark)
}
#endif
