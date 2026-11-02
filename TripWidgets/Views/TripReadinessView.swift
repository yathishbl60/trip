import SwiftUI
import WidgetKit

struct TripReadinessView: View {
    let presentation: TripReadinessPresentation
    @Environment(\.widgetFamily) private var family
    #if os(visionOS)
    @Environment(\.levelOfDetail) private var levelOfDetail
    #endif

    var body: some View {
        #if os(visionOS)
        if levelOfDetail == .simplified { TripReadinessGlanceView(presentation: presentation) }
        else { TripReadinessHomeView(presentation: presentation) }
        #else
        if family == .accessoryRectangular {
            TripReadinessGlanceView(presentation: presentation)
        } else { TripReadinessHomeView(presentation: presentation) }
        #endif
    }
}

#if DEBUG
#Preview("Readiness · sample") {
    TripReadinessView(presentation: TripReadinessPresentation(entry: TripWidgetFixtures.packing)).padding()
}
#endif
