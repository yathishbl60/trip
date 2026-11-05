import TripLocalization
import SwiftUI
import TripDomain

struct TripChecklistView: View {
    let tripID: UUID
    let controller: TripController
    @State private var confirmsReset = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if let trip = controller.model.library.trip(tripID) { content(trip) }
            else { ContentUnavailableView(TripText.tripUnavailable.resource, systemImage: "suitcase.rolling") }
        }
        .navigationTitle(TripText.checklist.resource)
        .tripWayfinding(.checklist, tripID: tripID, controller: controller)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
        .tripChecklistNamingAlert(controller, tripID: tripID)
        .sheet(isPresented: controller.packingPresentation(tripID)) {
            NavigationStack { TripPackingView(tripID: tripID, controller: controller) }
        }
        .confirmationDialog(TripText.markAllItemsIncomplete.resource, isPresented: $confirmsReset) {
            Button(TripText.resetChecklist.resource) { controller.resetChecklist(in: tripID) }
        }
    }

    private func content(_ trip: TripPlan) -> some View {
        List {
            overview(trip)
            TripChecklistSection(title: TripText.toDo.text, items: trip.pendingChecklistItems, tripID: tripID, controller: controller)
            TripChecklistSection(title: TripText.done.text, items: trip.completedChecklistItems, tripID: tripID, controller: controller)
            if trip.checklist.isEmpty { starter }
        }
        .animation(AppTheme.Motion.selection(reduceMotion: reduceMotion), value: trip.completedChecklistCount)
        .toolbar {
            TripChecklistToolbar(trip: trip, controller: controller, reset: { confirmsReset = true })
        }
    }

    private func overview(_ trip: TripPlan) -> some View {
        Section {
            if !trip.checklist.isEmpty {
                ProgressView(value: Double(trip.completedChecklistCount), total: Double(trip.checklist.count)) {
                    Text(trip.checklistSummary).font(.title2.bold())
                        .padding(.bottom, AppTheme.Spacing.small)
                }.padding(.vertical, AppTheme.Spacing.small)
            }
            Button(TripText.addItem.resource, systemImage: "plus") { controller.editChecklistItem(in: tripID) }
                .disabled(!trip.canAddChecklistItem)
        } footer: {
            if !trip.canAddChecklistItem { Text(TripText.checklistFullValueItems(TripText.number(TripLimits.checklistItems)).resource) }
        }
    }

    private var starter: some View {
        Section {
            ContentUnavailableView(TripText.noChecklistItems.resource, systemImage: "checklist",
                                   description: Text(TripText.addYourOwnItemsOrStartWithTravelEssentials.resource))
            Button(TripText.addTravelEssentials.resource, systemImage: "suitcase.rolling") {
                controller.addChecklistTemplate(.essentials, tripID: tripID)
            }
            Button(TripText.suggestAPackingList.resource, systemImage: "sparkles") { controller.openPacking(tripID) }
        }
    }
}

#if DEBUG
#Preview("Travel checklist") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack { TripChecklistView(tripID: model.library.trips[0].id, controller: TripController(model: model)) }
}
#Preview("Checklist · empty and large text") {
    let model = PreviewFixtures.tripPlanner(includeChecklist: false)
    let id = model.library.trips[0].id
    NavigationStack { TripChecklistView(tripID: id, controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Checklist completion · interactive, narrow") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack { TripChecklistView(tripID: model.library.trips[0].id, controller: TripController(model: model)) }
        .frame(width: 320).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
