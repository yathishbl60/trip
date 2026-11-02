#if os(iOS)
import SwiftUI

struct TripActivityGlanceView: View {
    let presentation: TripActivityPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(presentation.tripTitle).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
            Label(presentation.title, systemImage: presentation.symbol).font(.headline).lineLimit(2)
            if let detail = presentation.context { Text(detail).font(.caption2).lineLimit(1) }
            Text(presentation.subtitle).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .privacySensitive()
    }
}

#if DEBUG
#Preview("Watch and CarPlay · small activity") {
    TripActivityGlanceView(presentation: TripActivityPresentation(attributes: TripActivityFixtures.attributes,
        state: TripActivityFixtures.active, isStale: false)).frame(width: 180, height: 130)
}
#Preview("Small activity · stale, long name") {
    TripActivityGlanceView(presentation: TripActivityPresentation(attributes: TripActivityFixtures.attributes,
        state: TripActivityFixtures.longName, isStale: true)).frame(width: 180, height: 130)
}
#Preview("Small activity · completed") {
    TripActivityGlanceView(presentation: TripActivityPresentation(attributes: TripActivityFixtures.attributes,
        state: TripActivityFixtures.completed, isStale: false)).frame(width: 180, height: 130)
}
#endif
#endif
