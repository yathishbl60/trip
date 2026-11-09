#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import SwiftUI

/// The photo and glyph remain mounted while the marker changes size.
struct MarkerArtworkView: View {
    let place: Place
    let style: MarkerStyle
    var includesPhoto = true
    var isSaved = false
    private var showsPhoto: Bool { includesPhoto && place.hasAnnotationPhoto }
    private var symbolSize: CGFloat { style.hasLabel ? 22 : 16 }

    var body: some View {
        artwork
            .frame(width: style.photoSize.width, height: style.photoSize.height)
            .clipShape(.rect(cornerRadius: style.photoRadius))
            .overlay(alignment: .bottomTrailing) {
                if showsPhoto || isSaved { badge.transition(.opacity) }
            }
            .accessibilityHidden(true)
    }

    private var artwork: some View {
        ZStack {
            place.category.color.opacity(style == .dot ? 1 : 0.2)
            if showsPhoto {
                Image(decorative: place.category.photoName)
                    .resizable().scaledToFill()
                    .opacity(style.photoOpacity)
                    .transition(.opacity)
            }
            Image(systemName: place.category.symbol)
                .symbolVariant(.fill)
                .symbolRenderingMode(.monochrome)
                .font(.system(size: symbolSize, weight: .semibold))
                .foregroundStyle(.primary)
                .opacity(!showsPhoto && style != .dot ? 1 : 0)
        }
    }

    private var badge: some View {
        Image(systemName: isSaved ? "bookmark.fill" : place.category.symbol)
            .symbolVariant(.fill)
            .symbolRenderingMode(.monochrome)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.primary)
            .frame(width: 16, height: 16)
            .background(.background, in: .circle)
            .overlay { Circle().strokeBorder(place.category.color.opacity(0.4), lineWidth: 1) }
            .opacity(style.badgeOpacity)
    }
}

#if DEBUG
#Preview("Photo token to card artwork", traits: .sizeThatFitsLayout) {
    @Previewable @State var style = MarkerStyle.thumbnail
    VStack(spacing: 24) {
        MarkerArtworkView(place: PreviewFixtures.hotel, style: style)
            .frame(height: 90)
            .animation(.easeInOut(duration: 0.24), value: style)
        Picker("Style", selection: $style) {
            ForEach(MarkerStyle.allCases, id: \.self) { Text($0.title).tag($0) }
        }
        .pickerStyle(.segmented)
    }
    .frame(width: 340).padding()
}
#Preview("Compact image · dark", traits: .sizeThatFitsLayout) {
    MarkerArtworkView(place: PreviewFixtures.hotel, style: .thumbnail)
        .padding(24).preferredColorScheme(.dark)
}
#Preview("Every category glyph · dark", traits: .sizeThatFitsLayout) {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 18) {
        ForEach(PlaceCategory.allCases) { category in
            MarkerArtworkView(place: PreviewFixtures.place(category), style: .thumbnail, includesPhoto: false)
        }
    }
    .frame(width: 320).padding().preferredColorScheme(.dark)
}
#endif
