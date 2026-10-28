import TripLocalization
import AppIntents
import SwiftUI
import TripDomain

struct TripChecklistSnippetView: View {
    let plan: TripPlan
    let briefing: TripChecklistBriefing

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(briefing.title).font(.headline)
            Text(briefing.summary).font(.subheadline).foregroundStyle(.secondary)
            ForEach(Array(briefing.pending.prefix(3))) { item in
                Button(intent: SetTripChecklistItemIntent(item: SavedTripChecklistEntity(item, plan: plan), complete: true)) {
                    Label(item.title, systemImage: "circle").frame(maxWidth: .infinity, alignment: .leading)
                }.buttonStyle(.bordered).accessibilityLabel(TripText.markValueDone(item.title).resource)
            }
            if let url = TripSystemData.checklistURL(plan.id) { Link(TripText.openChecklist.text, destination: url) }
        }.padding().privacySensitive()
    }
}

#if DEBUG
#Preview("Siri · packing checklist") {
    let plan = PreviewFixtures.tripPlanner().library.trips[0]
    TripChecklistSnippetView(plan: plan, briefing: TripChecklistBriefing(plan))
}
#Preview("Siri · empty checklist · large text") {
    let plan = PreviewFixtures.tripPlanner(includeChecklist: false).library.trips[0]
    TripChecklistSnippetView(plan: plan, briefing: TripChecklistBriefing(plan)).dynamicTypeSize(.accessibility2)
}
#endif
