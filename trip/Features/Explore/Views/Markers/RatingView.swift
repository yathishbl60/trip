import TripLocalization
#if !TRIP_STANDALONE
import TripDomain
#endif
import SwiftUI

struct RatingView: View {
    let place: Place
    var showsReviews = true
    var showsCategory = false

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill").foregroundStyle(AppTheme.rating)
            Text(place.ratingText)
            if showsReviews { Text(place.reviewText) }
            if showsCategory {
                Text("|").foregroundStyle(.quaternary)
                Image(systemName: place.category.symbol).foregroundStyle(place.category.color)
            }
        }
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .accessibilityLabel(TripText.sampleRatingValueSampleReviewsValue(place.ratingText, TripText.number(place.reviews ?? 0)).resource)
    }
}

#if DEBUG
#Preview("Rating variations", traits: .sizeThatFitsLayout) {
    VStack(alignment: .leading, spacing: 16) {
        RatingView(place: PreviewFixtures.hotel)
        RatingView(place: PreviewFixtures.longName)
        RatingView(place: PreviewFixtures.hotel, showsReviews: false)
    }
    .padding()
}
#Preview("Accessibility · dark", traits: .sizeThatFitsLayout) {
    RatingView(place: PreviewFixtures.longName)
        .padding().dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
