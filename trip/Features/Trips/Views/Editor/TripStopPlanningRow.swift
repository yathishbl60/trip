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
    @ScaledMetric(relativeTo: .subheadline) private var railWidth = 32.0

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            HStack(alignment: .top, spacing: AppTheme.Spacing.tight) {
                place
                TripStopActionsMenu(stop: stop, dayID: dayID, tripID: tripID, controller: controller)
            }
            if let timing { visitTime(timing) }
            notes
        }
        .padding(.leading, railWidth + AppTheme.Spacing.medium)
        .overlay(alignment: .leading) {
            TripItineraryRail(number: number, color: stop.place.category.color, continuesSequence: continuesSequence,
                              isComplete: controller.model.hasVisited(stop.id, dayID: dayID, tripID: tripID))
        }
        .padding(.vertical, AppTheme.Spacing.tight)
        .appEntityIdentifier(controller.detailEntityIdentifier(tripID: tripID, itemID: stop.id))
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
#endif
