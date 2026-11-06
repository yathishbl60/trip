import TripLocalization
import SwiftUI
import MapEngine
import CoreGraphics

struct MapSearchStatusView: View {
    let model: CatalogModel
    var showsProgress = true
    var motion = MapMotion()
    var retry: (() -> Void)? = nil
    var areaChanged: (CGRect) -> Void = { _ in }
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ZStack {
            if isVisible { content.transition(.opacity) }
        }
        .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .global) }) { areaChanged(isVisible ? $0 : .null) }
        .onChange(of: isVisible) { _, visible in if !visible { areaChanged(.null) } }
        .onDisappear { areaChanged(.null) }
        .frame(maxWidth: 420)
        .padding(.horizontal, AppTheme.Spacing.edge)
        .animation(animation, value: isVisible)
        .animation(animation, value: message)
        .allowsHitTesting(!model.isSearching && model.canRetrySearch && retry != nil)
    }

    private var isVisible: Bool { showsProgress && !message.isEmpty }
    private var message: String { model.isSearching ? TripText.searching.text : model.status }
    private var animation: Animation? { reduceMotion ? nil : .easeOut(duration: motion.fade) }

    @ViewBuilder private var content: some View {
        if !model.isSearching, model.canRetrySearch, let retry {
            Button(action: retry) {
                // Keep the tap target outside the compact glass surface.
                notice.frame(minWidth: AppTheme.controlTarget, minHeight: AppTheme.controlTarget).contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(TripText.tryAgainValue(message).resource)
            .accessibilityHint(TripText.searchAgain.resource)
        } else {
            notice.frame(minHeight: AppTheme.controlTarget)
                .accessibilityElement(children: .ignore).accessibilityLabel(message)
        }
    }

    private var notice: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            if model.isSearching { ProgressView().controlSize(.mini).accessibilityHidden(true) }
            Text(message).lineLimit(typeSize.isAccessibilitySize ? nil : 1)
                .fixedSize(horizontal: false, vertical: true).layoutPriority(1)
            if !model.isSearching, model.canRetrySearch, retry != nil {
                Image(systemName: "arrow.clockwise").foregroundStyle(AppTheme.accent).accessibilityHidden(true)
            }
        }
        .font(.caption)
        .padding(.horizontal, AppTheme.Spacing.medium).padding(.vertical, AppTheme.Spacing.tight)
        .tripGlassSurface()
    }
}

#if DEBUG
#Preview("Searching · compact single line", traits: .sizeThatFitsLayout) {
    MapSearchStatusView(model: PreviewFixtures.searching().catalog).padding()
}
#Preview("Search offline · compact retry, dark", traits: .sizeThatFitsLayout) {
    MapSearchStatusView(model: PreviewFixtures.offline().catalog, retry: {}).padding().preferredColorScheme(.dark)
}
#Preview("Compact notice · accessibility text", traits: .sizeThatFitsLayout) {
    MapSearchStatusView(model: PreviewFixtures.searching().catalog)
        .padding().dynamicTypeSize(.accessibility2)
}
#Preview("Status transition · local preview") {
    @Previewable @State var model = PreviewFixtures.searching()
    VStack(spacing: AppTheme.spacing) {
        MapSearchStatusView(model: model.catalog)
        Button("Toggle finding places") { model.catalog.isSearching.toggle() }
    }.padding()
}
#Preview("Search notice · animations disabled", traits: .sizeThatFitsLayout) {
    MapSearchStatusView(model: PreviewFixtures.offline().catalog, motion: MapMotion(fade: 0)).padding()
}
#Preview("Error · narrow, full VoiceOver message", traits: .sizeThatFitsLayout) {
    MapSearchStatusView(model: PreviewFixtures.offline().catalog, retry: {})
        .frame(width: 280).dynamicTypeSize(.accessibility3).padding()
}
#endif
