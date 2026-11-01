import TripLocalization
import SwiftUI
import TripDomain

struct TripChecklistToolbar: ToolbarContent {
    let trip: TripPlan
    let controller: TripController
    let reset: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu(TripText.checklistOptions.resource, systemImage: "ellipsis") {
                Button(TripText.suggestAPackingList.resource, systemImage: "sparkles") { controller.openPacking(trip.id) }
                    .disabled(!trip.canAddChecklistItem)
                templates
                Button(TripText.resetChecklist.resource, systemImage: "arrow.counterclockwise", action: reset)
                    .disabled(trip.completedChecklistCount == 0)
                if controller.supportsSystemExports {
                    Button(TripText.exportToReminders.resource, systemImage: "checklist") {
                        controller.beginRemindersExport(tripID: trip.id)
                    }
                }
            }
        }
    }

    private var templates: some View {
        Menu(TripText.addAList.resource, systemImage: "text.badge.plus") {
            ForEach(TripChecklistTemplate.allCases) { template in
                Button(template.title) { controller.addChecklistTemplate(template, tripID: trip.id) }
            }
        }.disabled(!trip.canAddChecklistItem)
    }
}

#if DEBUG
#Preview("Checklist controls") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        Text("Checklist").toolbar {
            TripChecklistToolbar(trip: model.library.trips[0], controller: TripController(model: model), reset: {})
        }
    }
}
#endif
