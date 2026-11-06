#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import SwiftUI

struct AnnotationRatingView: View {
    let place: Place
    var showsReviews = false

    var body: some View {
        HStack(spacing: MarkerStyle.captionSpacing) {
            Image(systemName: place.annotationSubtitleSymbol)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(place.rating == nil ? Color.secondary : AppTheme.rating)
            Text(place.annotationSubtitle)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(place.rating == nil ? Color.secondary : .primary)
                .layoutPriority(1)
            if showsReviews, place.rating != nil {
                Text(place.reviewText).font(.system(size: 10)).foregroundStyle(.secondary)
            }
        }
        .lineLimit(1)
        .truncationMode(.tail)
        .frame(height: MarkerStyle.metadataHeight)
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
#Preview("Live categories · actual caption width") {
    VStack(alignment: .leading, spacing: 16) {
        ForEach(PlaceCategory.allCases) { category in
            let place = Place(id: category.rawValue, name: category.title, coordinate: .bangkok,
                              category: category, importance: 1, rating: nil, reviews: nil, isLive: true)
            AnnotationRatingView(place: place, showsReviews: true)
        }
    }.frame(width: 110).padding().preferredColorScheme(.dark)
}
#endif
