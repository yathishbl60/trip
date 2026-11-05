import TripLocalization
import SwiftUI
import TripDomain

struct TripStopTimingView: View {
    let draft: TripStopTimingDraft
    let controller: TripController

    var body: some View {
        NavigationStack {
            form
            .navigationTitle(TripText.visitTime.resource).navigationBarTitleDisplayMode(.inline)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .toolbar { tools }
        }
        .presentationDetents([.large]).presentationDragIndicator(.visible).presentationSizing(.form)
        .tripDraftDismissal(draft, controller: controller) { controller.cancelStopTiming(draft) }
    }

    private var form: some View {
        Form {
            Section { Text(draft.title).font(.headline) }
            visit
            travel
            fixedArrival
            if let timing = draft.preview(in: controller.model.library.trip(draft.tripID)) {
                Section(TripText.plannedVisit.resource) { TripStopTimeView(timing: timing, showsDetails: true) }
            }
            if let error = draft.error { TripWarningLabel(message: error) }
        }
    }

    private var visit: some View {
        Section(TripText.visit.resource) {
            TripDurationControl(label: TripText.durationValue(TripScheduleText.duration(draft.timing.visitMinutes)).text,
                                minutes: controller.timingSlider(\.visitMinutes, draft: draft), range: TripLimits.visitMinutes)
        }
    }

    private var travel: some View {
        Section {
            TripDurationControl(label: TripText.travelValue(TripScheduleText.duration(draft.timing.travelMinutes)).text,
                                minutes: controller.timingSlider(\.travelMinutes, draft: draft), range: TripLimits.travelMinutes)
            TripDurationControl(label: TripText.bufferValue(TripScheduleText.duration(draft.timing.bufferMinutes)).text,
                                minutes: controller.timingSlider(\.bufferMinutes, draft: draft), range: TripLimits.bufferMinutes)
        } header: { Text(draft.isFirst ? TripText.toTheFirstPlace.text : TripText.fromThePreviousStop.text) } footer: {
            Text(TripText.manualAllowancesIncludingExtraTimeBetweenStops.resource)
        }
    }

    private var fixedArrival: some View {
        Section {
            Toggle(TripText.fixedArrival.resource, isOn: controller.fixedArrival(draft))
            if draft.fixesArrival {
                DatePicker(TripText.arriveAt.resource, selection: controller.arrival(draft), in: draft.arrivalRange,
                           displayedComponents: [.date, .hourAndMinute])
                    .environment(\.timeZone, draft.utc.timeZone).environment(\.calendar, draft.utc)
                TripStopClockReviewView(draft: draft, controller: controller)
            }
        } footer: {
            Text(TripText.forReservationsOrTimedEntryConflictsAppearInYour.resource)
        }
    }

    @ToolbarContentBuilder private var tools: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(TripText.cancel.resource) {
                controller.requestDiscard(draft) { controller.cancelStopTiming(draft) }
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(TripText.save.resource) { controller.saveStopTiming(draft) }
                .buttonStyle(TripButtonStyles.prominent).tint(AppTheme.accentFill)
        }
    }
}

#if DEBUG
#Preview("Edit a visit · fixed arrival") {
    let model = TripSchedulePreview.planner(overloaded: true)
    let trip = model.library.trips[0]
    TripStopTimingView(draft: TripStopTimingDraft(trip: trip, day: trip.days[0], stop: trip.days[0].stops[1]),
                       controller: TripController(model: model))
}
#Preview("Visit timing · discard · large text") {
    let model = TripSchedulePreview.planner()
    let trip = model.library.trips[0]
    let draft = TripStopTimingDraft(trip: trip, day: trip.days[0], stop: trip.days[0].stops[0])
    draft.timing.visitMinutes += 5
    draft.isDiscarding = true
    return TripStopTimingView(draft: draft, controller: TripController(model: model))
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
