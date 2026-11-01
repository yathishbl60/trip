import TripLocalization
import SwiftUI
import TripDomain

struct TripStopOrderView: View {
    let draft: TripStopOrderModel
    let controller: TripController
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        NavigationStack {
            List {
                if let proposal = draft.proposal {
                    TripStopOrderSummary(proposal: proposal)
                    order(proposal)
                } else if draft.notice == nil { ProgressView(TripText.comparingStopOrders.resource) }
                if let notice = draft.notice { Text(notice).foregroundStyle(.secondary) }
                changedDayNotice
            }
            .navigationTitle(TripText.valueStopOrder(draft.day.title).resource)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { actions }
        }
        .task { await controller.loadStopOrder(draft) }
    }

    private func order(_ proposal: TripStopOrderProposal) -> some View {
        Section {
            if proposal.hasImprovement {
                orderPicker
            }
            ForEach(Array(draft.stops.enumerated()), id: \.element.id) { index, stop in
                TripNumberedStopRow(place: stop.place, number: index + 1)
            }
        } header: { Text(TripText.stopOrder.resource) }
    }

    @ViewBuilder private var changedDayNotice: some View {
        if draft.proposal?.hasImprovement == true, !controller.model.canApplyStopOrder(draft) {
            Section {
                Label(TripText.thisDayChangedOrIsBeingTrackedTryA.resource,
                      systemImage: "info.circle").foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder private var orderPicker: some View {
        if typeSize.isAccessibilitySize { picker.pickerStyle(.menu) }
        else { picker.pickerStyle(.segmented) }
    }

    private var picker: some View {
        Picker(TripText.stopOrder.resource, selection: controller.originalOrder(draft)) {
            Text(TripText.suggested.resource).tag(false)
            Text(TripText.current.resource).tag(true)
        }
    }

    @ToolbarContentBuilder private var actions: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(TripText.cancel.resource) { controller.closeStopOrder(draft.id) }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(TripText.useSuggestion.resource) { controller.applyStopOrder(draft) }
                .disabled(!controller.model.canApplyStopOrder(draft))
        }
    }
}

#if DEBUG
#Preview("Suggested order · large text") {
    let (model, draft) = TripStopOrderPreview.fixture()
    TripStopOrderView(draft: draft, controller: TripController(model: model))
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Suggestion became stale") {
    let (model, draft) = TripStopOrderPreview.fixture()
    let _ = model.library.updateDay(draft.day.id, in: draft.tripID) { day in
        day.stops.swapAt(1, 2)
        return true
    }
    TripStopOrderView(draft: draft, controller: TripController(model: model))
}
#Preview("Review stop order · local calculation") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    let day = trip.days[0]
    let proposal = TripStopOrderProposal(day: day, suggestedIDs: day.stops.map(\.id),
        originalDistance: 2000, suggestedDistance: 2000)
    TripStopOrderView(draft: TripStopOrderModel(tripID: trip.id, day: day, service: model.stopOrdering, proposal: proposal),
                     controller: TripController(model: model))
}
#endif
