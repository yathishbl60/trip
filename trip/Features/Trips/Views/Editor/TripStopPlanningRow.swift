import TripLocalization
import TripDomain
import SwiftUI
import AppIntents

struct TripStopPlanningRow: View {
    let stop: TripStop
    let dayID: UUID
    let tripID: UUID
    let controller: TripController
    var number = 1
    var timing: TripTimelineEntry? = nil
    var continuesSequence = false
    @Environment(\.editMode) private var editMode
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            identityAndActions
            if let timing { visitTime(timing) }
            notes
        }
        .modifier(TripItineraryRowLayout(number: number, color: stop.place.category.color, continuesSequence: continuesSequence,
                                         isComplete: controller.model.hasVisited(stop.id, dayID: dayID, tripID: tripID)))
        .padding(.vertical, AppTheme.Spacing.tight)
        .appEntityIdentifier(controller.detailEntityIdentifier(tripID: tripID, itemID: stop.id))
    }

    private var identityAndActions: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: AppTheme.Spacing.tight))
            : AnyLayout(HStackLayout(alignment: .top, spacing: AppTheme.Spacing.tight))
        return layout {
            place
            TripStopActionsMenu(stop: stop, dayID: dayID, tripID: tripID, controller: controller)
        }
    }

    private func visitTime(_ timing: TripTimelineEntry) -> some View {
        Button { controller.beginStopTiming(stopID: stop.id, dayID: dayID, tripID: tripID) } label: {
            TripStopTimeView(timing: timing)
                .frame(maxWidth: .infinity, minHeight: AppTheme.controlTarget, alignment: .leading)
                .contentShape(.rect)
        }
        .buttonStyle(.plain).accessibilityHint(TripText.editVisitTime.resource)
    }

    @ViewBuilder private var notes: some View {
        if editMode?.wrappedValue.isEditing == true {
            TextField(TripText.notesForThisStop.resource, text: controller.stopNotes(stop.id, dayID: dayID,
                                                                      tripID: tripID), axis: .vertical)
                .font(.subheadline).lineLimit(1...3)
        } else if !stop.notes.isEmpty {
            Text(stop.notes).font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private var place: some View {
        Button { controller.showOnMap(stop.place) } label: {
            TripNumberedStopRow(place: stop.place, number: number, showsNumber: false)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .hoverEffect(.highlight)
        .accessibilityHint(TripText.showThisPlaceOnTheMap.resource)
        .accessibilityValue(controller.model.hasVisited(stop.id, dayID: dayID, tripID: tripID) ? TripText.visited.text : "")
    }
}

#if DEBUG
#Preview("Itinerary stop", traits: .sizeThatFitsLayout) {
    let model = PreviewFixtures.tripPlanner()
    TripStopPlanningRow(stop: model.library.trips[0].days[0].stops[0],
                        dayID: model.library.trips[0].days[0].id,
                        tripID: model.library.trips[0].id,
                        controller: TripController(model: model)).padding()
}
#Preview("Stop notes · dark", traits: .sizeThatFitsLayout) {
    let model = PreviewFixtures.tripPlanner()
    TripStopPlanningRow(stop: model.library.trips[0].days[0].stops[0],
                        dayID: model.library.trips[0].days[0].id,
                        tripID: model.library.trips[0].id,
                        controller: TripController(model: model))
        .padding().preferredColorScheme(.dark)
}
#Preview("Stop actions · large text in a narrow list") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    List {
        TripStopPlanningRow(stop: trip.days[0].stops[0], dayID: trip.days[0].id, tripID: trip.id,
                            controller: TripController(model: model))
    }.frame(width: 320).dynamicTypeSize(.accessibility3).environment(\.editMode, .constant(.active))
}
#endif
