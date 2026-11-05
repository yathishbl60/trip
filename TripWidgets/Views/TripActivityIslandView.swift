#if os(iOS)
import SwiftUI

/// Expanded Island content; the surrounding regions already show the symbol and progress.
struct TripActivityIslandView: View {
    let attributes: TripActivityAttributes
    let state: TripActivityAttributes.ContentState
    let presentation: TripActivityPresentation
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: WidgetTheme.Spacing.tight) {
            Text(presentation.title).font(.headline).lineLimit(2)
            if let detail = presentation.context { Text(detail).font(.caption).lineLimit(1) }
            footer
        }.privacySensitive()
    }

    private var footer: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: WidgetTheme.Spacing.small))
            : AnyLayout(HStackLayout(spacing: WidgetTheme.Spacing.medium))
        return layout {
            Text(presentation.tripTitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            TripActivityActions(attributes: attributes, state: state, presentation: presentation)
        }
    }
}

#if DEBUG
#Preview("Expanded Island content · long place") {
    let attributes = TripActivityFixtures.attributes
    let state = TripActivityFixtures.longName
    TripActivityIslandView(attributes: attributes, state: state,
        presentation: TripActivityPresentation(attributes: attributes, state: state, isStale: false))
        .frame(width: 320).preferredColorScheme(.dark)
}
#Preview("Expanded Island · accessibility") {
    let attributes = TripActivityFixtures.attributes
    let state = TripActivityFixtures.longName
    TripActivityIslandView(attributes: attributes, state: state,
        presentation: TripActivityPresentation(attributes: attributes, state: state, isStale: false))
        .frame(width: 320).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
#endif
