#if os(iOS) || os(visionOS)
import SwiftUI

struct DirectionsRouteLabel: View {
    let route: DirectionsRoute
    let label: String
    let isSelected: Bool
    var appearance = DirectionsAppearance()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(route.estimate.durationText).font(.headline).lineLimit(1).minimumScaleFactor(0.8)
            Text(label).font(.subheadline).lineLimit(1).minimumScaleFactor(0.8)
        }
        .frame(width: DirectionsRoute.labelSize.width, height: DirectionsRoute.labelSize.height)
        .foregroundStyle(isSelected ? appearance.calloutText : .primary)
        .background(isSelected ? appearance.calloutFill : .clear, in: .rect(cornerRadius: 16))
        .background(.regularMaterial, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#if DEBUG
#Preview("Selected route callout", traits: .sizeThatFitsLayout) {
    let model = DirectionsPreviewFixtures.ready()
    if let route = model.routes.first {
        DirectionsRouteLabel(route: route, label: "Selected", isSelected: true).padding()
    }
}
#Preview("Alternative · dark", traits: .sizeThatFitsLayout) {
    let model = DirectionsPreviewFixtures.ready()
    if let route = model.routes.last {
        DirectionsRouteLabel(route: route, label: "Fastest", isSelected: false).padding().preferredColorScheme(.dark)
    }
}
#Preview("Selected route · dark", traits: .sizeThatFitsLayout) {
    let model = DirectionsPreviewFixtures.ready()
    if let route = model.routes.first {
        DirectionsRouteLabel(route: route, label: "Fastest", isSelected: true)
            .padding().preferredColorScheme(.dark)
    }
}
#endif
#endif
