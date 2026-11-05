import SwiftUI
import AppIntents
import TripDomain

struct TripEventRow: View {
    let model: TripEventPresentation
    let controller: TripController
    let continuesSequence: Bool
    @ScaledMetric(relativeTo: .subheadline) private var railWidth = 32.0

    var body: some View {
        Button {
            controller.beginEvent(dayID: model.day.id, tripID: model.trip.id, eventID: model.event.id)
        } label: {
            details
                .frame(maxWidth: .infinity, minHeight: AppTheme.controlTarget, alignment: .leading)
                .padding(.leading, railWidth + AppTheme.Spacing.medium)
                .overlay(alignment: .leading) {
                    TripItineraryRail(number: 0, color: AppTheme.accent, continuesSequence: continuesSequence,
                                      symbol: model.event.kind.symbol)
                }
                .padding(.vertical, AppTheme.Spacing.tight).contentShape(.rect)
        }
        .buttonStyle(.plain).accessibilityHint(model.accessibilityHint)
        .hoverEffect(.highlight)
        .appEntityIdentifier(controller.detailEntityIdentifier(tripID: model.trip.id, itemID: model.event.id))
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Text(model.event.title).font(.headline).foregroundStyle(.primary)
            Text(model.spanText).font(.caption).foregroundStyle(.secondary)
            if model.showsTime { Text(model.timeText).font(.subheadline).foregroundStyle(.primary) }
            if !model.locationText.isEmpty { Text(model.locationText).font(.subheadline).foregroundStyle(.secondary) }
            if !model.event.notes.isEmpty {
                Text(model.event.notes).font(.footnote).foregroundStyle(.secondary).lineLimit(2)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Flight and stay") {
    let model = TripJourneyPreview.planner()
    let trip = model.library.trips[0]
    List {
        ForEach(trip.events) { event in
            TripEventRow(model: TripEventPresentation(event: event, day: trip.days[0], trip: trip),
                         controller: TripController(model: model), continuesSequence: true)
        }
    }
}
#Preview("Continuing stay · large text") {
    let model = TripJourneyPreview.planner()
    let trip = model.library.trips[0]
    List {
        TripEventRow(model: TripEventPresentation(event: trip.events[1], day: trip.days[1], trip: trip),
                     controller: TripController(model: model), continuesSequence: false)
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
