#if os(iOS)
import AppIntents
import SwiftUI
import WidgetKit

struct TripActivityView: View {
    let attributes: TripActivityAttributes
    let state: TripActivityAttributes.ContentState
    let isStale: Bool
    private var presentation: TripActivityPresentation {
        TripActivityPresentation(attributes: attributes, state: state, isStale: isStale)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(presentation.tripTitle).font(.caption.weight(.semibold)).foregroundStyle(.secondary).lineLimit(1)
            Text(presentation.title).font(.headline).lineLimit(2)
            if let detail = presentation.context { Text(detail).font(.caption).lineLimit(1) }
            HStack(spacing: 12) {
                Text(presentation.subtitle).font(.caption).foregroundStyle(.secondary)
                Spacer(minLength: 0)
                TripActivityActions(attributes: attributes, state: state, presentation: presentation)
            }
        }
        .padding()
        .privacySensitive()
    }

}

#if DEBUG
#Preview("Lock Screen · active sample") {
    TripActivityView(attributes: TripActivityFixtures.attributes, state: TripActivityFixtures.active, isStale: false)
}
#Preview("Lock Screen · expired sample") {
    TripActivityView(attributes: TripActivityFixtures.attributes, state: TripActivityFixtures.active, isStale: true)
}
#Preview("Lock Screen · long name, accessibility") {
    TripActivityView(attributes: TripActivityFixtures.attributes, state: TripActivityFixtures.longName, isStale: false)
        .frame(width: 350).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
#endif
