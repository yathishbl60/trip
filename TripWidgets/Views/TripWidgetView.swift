import SwiftUI
import TripDomain
import WidgetKit

struct TripWidgetView: View {
    let entry: TripWidgetEntry
    @Environment(\.widgetFamily) private var family
    #if os(visionOS)
    @Environment(\.levelOfDetail) private var levelOfDetail
    #endif

    var body: some View {
        #if os(visionOS)
        if levelOfDetail == .simplified { TripWidgetGlanceView(entry: entry) }
        else { content }
        #else
        content
        #endif
    }

    @ViewBuilder private var content: some View {
        switch family {
        #if os(iOS)
        case .accessoryInline: Text("\(entry.title) · \(entry.stopTitle)")
        #endif
        case .accessoryCircular: circular
        case .accessoryRectangular: accessory
        default: TripWidgetHomeView(entry: entry, expanded: family == .systemMedium)
        }
    }

    private var accessory: some View {
        VStack(alignment: .leading, spacing: WidgetTheme.Spacing.compact) {
            Label(entry.title, systemImage: "suitcase.rolling").font(.headline).lineLimit(1)
            Text(entry.stopTitle).lineLimit(1)
            Text(entry.isTracking ? entry.progress : entry.detail).font(.caption).lineLimit(1)
        }
    }

    @ViewBuilder private var circular: some View {
        if entry.isTracking { trackingGauge }
        else {
            Image(systemName: entry.item?.symbol ?? "suitcase.rolling")
                .accessibilityLabel("\(entry.title), \(entry.stopTitle), \(entry.detail)")
        }
    }

    private var trackingGauge: some View {
        Gauge(value: Double(entry.visited), in: 0...Double(max(entry.total, 1))) {
            Image(systemName: "suitcase.rolling")
        } currentValueLabel: {
            Text("\(entry.visited)/\(entry.total)")
        }
        .gaugeStyle(.accessoryCircular)
        .accessibilityLabel("\(entry.title), \(entry.progress)")
    }
}

#if DEBUG
#if os(iOS)
#Preview("Lock Screen · sample", as: .accessoryRectangular) {
    TripItineraryWidget()
} timeline: {
    TripWidgetFixtures.active
}
#Preview("Lock Screen · flight after visits", as: .accessoryRectangular) {
    TripItineraryWidget()
} timeline: {
    TripWidgetFixtures.flightAfterVisits
}
#Preview("Circular · flight after visits", as: .accessoryCircular) {
    TripItineraryWidget()
} timeline: {
    TripWidgetFixtures.flightAfterVisits
}
#endif
#Preview("Empty widget", as: .systemSmall) {
    TripItineraryWidget()
} timeline: {
    TripWidgetEntry(date: TripWidgetFixtures.date)
}
#endif
