#if !TRIP_STANDALONE
import TripDomain
#endif
import SwiftUI

struct CategoryBadge: View {
    let category: PlaceCategory
    var diameter: CGFloat = 30
    @Environment(\.colorSchemeContrast) private var contrast

    var body: some View {
        Image(systemName: category.symbol)
            .symbolVariant(.fill)
            .symbolRenderingMode(.monochrome)
            .font(.system(size: diameter * 0.48, weight: .bold))
            .foregroundStyle(category.color)
            .frame(width: diameter, height: diameter)
            .background(category.color.opacity(0.14), in: .circle)
            .background(.background, in: .circle)
            .overlay { Circle().strokeBorder(.primary.opacity(contrast == .increased ? 0.6 : 0.12), lineWidth: 1) }
            .shadow(color: .black.opacity(0.09), radius: 5, y: 3)
            .accessibilityHidden(true)
    }
}

#Preview("Every category", traits: .sizeThatFitsLayout) {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))], spacing: 18) {
        ForEach(PlaceCategory.allCases) { category in
            CategoryBadge(category: category, diameter: 44)
        }
    }
    .frame(width: 280).padding()
}
#Preview("Badge sizes · dark", traits: .sizeThatFitsLayout) {
    HStack(spacing: 16) {
        CategoryBadge(category: .hotel, diameter: 23)
        CategoryBadge(category: .hotel)
        CategoryBadge(category: .hotel, diameter: 44)
    }
    .padding().preferredColorScheme(.dark)
}
#Preview("Every category · dark", traits: .sizeThatFitsLayout) {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))], spacing: 18) {
        ForEach(PlaceCategory.allCases) { category in CategoryBadge(category: category, diameter: 44) }
    }
    .frame(width: 280).padding().preferredColorScheme(.dark)
}
