#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import SwiftUI

struct MarkerSurfaceView: View {
    let category: PlaceCategory
    let style: MarkerStyle
    var isSelected = false
    @Environment(\.colorSchemeContrast) private var contrast
    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: style.surfaceRadius) }

    var body: some View {
        shape
            .fill(.background)
            .overlay { shape.fill(category.color.opacity(isSelected ? 0.12 : 0)) }
            .overlay {
                shape.strokeBorder(isSelected ? category.color : .primary.opacity(contrast == .increased ? 0.6 : 0.12),
                                   lineWidth: isSelected ? 2.5 : 1)
            }
            .shadow(color: .black.opacity(0.16), radius: style.shadowRadius, y: style.shadowOffset)
            .accessibilityHidden(true)
    }
}

#Preview("Quiet surface and selection", traits: .sizeThatFitsLayout) {
    HStack(spacing: 24) {
        MarkerSurfaceView(category: .hotel, style: .card)
        MarkerSurfaceView(category: .hotel, style: .card, isSelected: true)
    }
    .frame(width: 392, height: 64).padding(24)
}
#Preview("Dark surface", traits: .sizeThatFitsLayout) {
    MarkerSurfaceView(category: .park, style: .card, isSelected: true)
        .frame(width: 184, height: 64).padding(24).preferredColorScheme(.dark)
}
