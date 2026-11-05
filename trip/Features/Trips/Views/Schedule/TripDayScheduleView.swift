import TripLocalization
import SwiftUI
import TripDomain

struct TripDayScheduleView: View {
    let draft: TripDayScheduleDraft
    let controller: TripController

    var body: some View {
        NavigationStack {
            Form {
                settings
                if let timeline = draft.preview(in: controller.model.library.trip(draft.tripID)) {
                    Section(TripText.yourDay.resource) { TripScheduleSummaryView(timeline: timeline, showsTarget: true) }
                }
                if let error = draft.error { TripWarningLabel(message: error) }
            }
            .navigationTitle(TripText.valueSchedule(draft.title).resource).navigationBarTitleDisplayMode(.inline)
            #if os(iOS)
            .scrollEdgeEffectStyle(.soft, for: .top)
            #endif
            .toolbar { tools }
        }
        .presentationDetents([.large]).presentationDragIndicator(.visible)
        .presentationSizing(.form)
        .tripDraftDismissal(draft, controller: controller) { controller.cancelDaySchedule(draft) }
        .environment(\.timeZone, draft.calendar.timeZone).environment(\.calendar, draft.calendar)
    }

    private var settings: some View {
        Section {
            Toggle(TripText.scheduleThisDay.resource, isOn: controller.scheduleEnabled(draft))
            if draft.enabled { timeFields }
        } footer: {
            if draft.enabled {
                Text(TripText.valueTimeZoneValue(draft.endExplanation, draft.calendar.timeZone.identifier).resource)
            } else {
                Text(TripText.turningOffTheScheduleKeepsYourPlacesAndSaved.resource)
            }
        }
    }

    private var timeFields: some View {
        Group {
            DatePicker(TripText.firstArrival.resource, selection: controller.scheduleStart(draft), displayedComponents: .hourAndMinute)
            if let clock = draft.startClock, clock.candidates.count > 1 {
                TripRepeatedTimePickerView(clock: clock, selection: controller.scheduleOccurrence(draft, end: false))
            }
            DatePicker(TripText.targetFinish.resource, selection: controller.scheduleEnd(draft), displayedComponents: .hourAndMinute)
            if let clock = draft.endClock, clock.candidates.count > 1 {
                TripRepeatedTimePickerView(clock: clock, selection: controller.scheduleOccurrence(draft, end: true))
            }
            if let issue = draft.clockIssue { TripWarningLabel(message: issue) }
        }.environment(\.timeZone, draft.utc.timeZone).environment(\.calendar, draft.utc)
    }

    @ToolbarContentBuilder private var tools: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(TripText.cancel.resource) {
                controller.requestDiscard(draft) { controller.cancelDaySchedule(draft) }
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(TripText.save.resource) { controller.saveDaySchedule(draft) }
                .buttonStyle(TripButtonStyles.prominent).tint(AppTheme.accentFill)
        }
    }
}

#if DEBUG
#Preview("Plan a day") {
    let model = TripSchedulePreview.planner()
    let trip = model.library.trips[0]
    TripDayScheduleView(draft: TripDayScheduleDraft(trip: trip, day: trip.days[0]),
                        controller: TripController(model: model))
}
#Preview("Schedule warnings · large text") {
    let model = TripSchedulePreview.planner(overloaded: true)
    let trip = model.library.trips[0]
    TripDayScheduleView(draft: TripDayScheduleDraft(trip: trip, day: trip.days[0]),
                        controller: TripController(model: model))
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Discard changed schedule · accessibility") {
    let model = TripSchedulePreview.planner()
    let trip = model.library.trips[0]
    let draft = TripDayScheduleDraft(trip: trip, day: trip.days[0])
    draft.enabled = false
    draft.isDiscarding = true
    return TripDayScheduleView(draft: draft, controller: TripController(model: model))
        .dynamicTypeSize(.accessibility2)
}
#endif
