import SwiftUI
import WidgetKit
import TripDomain

struct TripReadinessHomeView: View {
    let presentation: TripReadinessPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(presentation.countdown, systemImage: "suitcase.rolling").font(.caption.weight(.semibold))
                .foregroundStyle(WidgetTheme.accent).lineLimit(2).widgetAccentable()
            Text(presentation.entry.title).font(.headline).lineLimit(2)
            Spacer(minLength: 0)
            if let progress = presentation.progress, progress.total > 0 {
                ProgressView(value: Double(progress.completed), total: Double(progress.total))
                    .tint(WidgetTheme.accent).accessibilityLabel(presentation.summary)
            }
            Text(presentation.status).font(.subheadline.weight(.semibold)).lineLimit(2)
            Text(presentation.departureText).font(.caption).foregroundStyle(.secondary).lineLimit(1)
        }
    }
}

#if DEBUG
#Preview("Packing · progress") {
    TripReadinessHomeView(presentation: TripReadinessPresentation(entry: TripWidgetFixtures.packing)).padding()
}
#Preview("Packing · legacy snapshot") {
    TripReadinessHomeView(presentation: TripReadinessPresentation(entry: TripWidgetFixtures.planned)).padding()
}
#Preview("Packing · empty library · dark") {
    TripReadinessHomeView(presentation: TripReadinessPresentation(entry: TripWidgetEntry(date: .distantPast)))
        .padding().preferredColorScheme(.dark)
}
#endif
