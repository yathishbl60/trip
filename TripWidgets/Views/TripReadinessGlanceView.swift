import SwiftUI

struct TripReadinessGlanceView: View {
    let presentation: TripReadinessPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(presentation.entry.title, systemImage: "checklist").font(.headline).lineLimit(1)
            Text(presentation.countdown).font(.caption).lineLimit(1)
            Text(presentation.summary).font(.caption).lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Checklist glance · sample") {
    TripReadinessGlanceView(presentation: TripReadinessPresentation(entry: TripWidgetFixtures.packing))
}
#endif
