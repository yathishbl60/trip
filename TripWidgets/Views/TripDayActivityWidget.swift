#if os(iOS)
import ActivityKit
import SwiftUI
import WidgetKit

struct TripDayActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TripActivityAttributes.self) { context in
            TripActivitySurfaceView(attributes: context.attributes, state: context.state, isStale: context.isStale)
                .activityBackgroundTint(.clear)
                .privacySensitive()
        } dynamicIsland: { context in island(context) }
        .supplementalActivityFamilies([.small, .medium])
    }

    private func island(_ context: ActivityViewContext<TripActivityAttributes>) -> DynamicIsland {
        let presentation = TripActivityPresentation(attributes: context.attributes, state: context.state, isStale: context.isStale)
        return DynamicIsland {
            DynamicIslandExpandedRegion(.leading) { Image(systemName: presentation.symbol).foregroundStyle(WidgetTheme.accent).privacySensitive() }
            DynamicIslandExpandedRegion(.trailing) {
                Text(presentation.compactText).monospacedDigit().privacySensitive().accessibilityLabel(presentation.subtitle)
            }
            DynamicIslandExpandedRegion(.bottom) {
                TripActivityIslandView(attributes: context.attributes, state: context.state, presentation: presentation)
            }
        } compactLeading: {
            Image(systemName: presentation.symbol).foregroundStyle(WidgetTheme.accent)
                .privacySensitive().accessibilityLabel(presentation.title)
        } compactTrailing: {
            Text(presentation.compactText).font(.caption2).monospacedDigit().privacySensitive().accessibilityLabel(presentation.subtitle)
        }
          minimal: { Image(systemName: presentation.symbol).privacySensitive().accessibilityLabel(presentation.title) }
        .keylineTint(WidgetTheme.accent)
        .widgetURL(presentation.destinationURL)
    }
}

#if DEBUG
#Preview("Trip day · sample", as: .content, using: TripActivityFixtures.attributes) {
    TripDayActivityWidget()
} contentStates: { TripActivityFixtures.active }
#Preview("Dynamic Island · compact", as: .dynamicIsland(.compact), using: TripActivityFixtures.attributes) {
    TripDayActivityWidget()
} contentStates: { TripActivityFixtures.active }
#Preview("Dynamic Island · minimal", as: .dynamicIsland(.minimal), using: TripActivityFixtures.attributes) {
    TripDayActivityWidget()
} contentStates: { TripActivityFixtures.active }
#Preview("Completed day", as: .content, using: TripActivityFixtures.attributes) {
    TripDayActivityWidget()
} contentStates: { TripActivityFixtures.completed }
#Preview("Dynamic Island · sample", as: .dynamicIsland(.expanded), using: TripActivityFixtures.attributes) {
    TripDayActivityWidget()
} contentStates: { TripActivityFixtures.active }
#endif
#endif
