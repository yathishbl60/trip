#if os(iOS)
import SwiftUI
import WidgetKit

struct TripActivitySurfaceView: View {
    let attributes: TripActivityAttributes
    let state: TripActivityAttributes.ContentState
    let isStale: Bool
    @Environment(\.activityFamily) private var family
    private var presentation: TripActivityPresentation {
        TripActivityPresentation(attributes: attributes, state: state, isStale: isStale)
    }

    var body: some View {
        Group {
            if family == .small { TripActivityGlanceView(presentation: presentation) }
            else { TripActivityView(attributes: attributes, state: state, isStale: isStale) }
        }
        .widgetURL(presentation.destinationURL)
        .privacySensitive()
    }
}

#if DEBUG
#Preview("Small activity routing · local") {
    TripActivitySurfaceView(attributes: TripActivityFixtures.attributes, state: TripActivityFixtures.active, isStale: false)
        .environment(\.activityFamily, .small).frame(width: 180, height: 130)
}
#Preview("Standard activity routing · local") {
    TripActivitySurfaceView(attributes: TripActivityFixtures.attributes, state: TripActivityFixtures.active, isStale: false)
        .environment(\.activityFamily, .medium).frame(width: 350)
}
#endif
#endif
