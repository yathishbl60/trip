#if os(iOS)
import SwiftUI

/// Expanded Island content; the surrounding regions already show the symbol and progress.
struct TripActivityIslandView: View {
    let attributes: TripActivityAttributes
    let state: TripActivityAttributes.ContentState
    let presentation: TripActivityPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(presentation.title).font(.headline).lineLimit(2)
            if let detail = presentation.context { Text(detail).font(.caption).lineLimit(1) }
            HStack(spacing: 12) {
                Text(presentation.tripTitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                Spacer(minLength: 0)
                TripActivityActions(attributes: attributes, state: state, presentation: presentation)
            }
        }.privacySensitive()
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
#endif
#endif
