import TripLocalization
import SwiftUI
import TripDomain

struct TripDayAddRow: View {
    let day: TripDay
    let trip: TripPlan
    let controller: TripController

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            addPlaces
            Menu {
                TripDayAddActions(day: day, trip: trip, controller: controller, includesPlaces: false)
            } label: {
                Image(systemName: "calendar.badge.plus")
                    .frame(minWidth: AppTheme.controlTarget, minHeight: AppTheme.controlTarget)
            }.accessibilityLabel(TripText.addAnEventToValue(day.title).resource)
                .accessibilityHint(TripText.flightsTrainsStaysReservationsActivitiesOrFreeTime.resource)
        }.buttonStyle(.borderless)
    }

    private var addPlaces: some View {
        Button { controller.beginSavedPlaces(dayID: day.id, tripID: trip.id) } label: {
            Label(TripText.addPlaces.resource, systemImage: "plus")
                .frame(maxWidth: .infinity, minHeight: AppTheme.controlTarget, alignment: .leading)
                .contentShape(.rect)
        }.disabled(day.stops.count >= TripLimits.stops)
            .accessibilityLabel(TripText.addPlacesToValue(day.title).resource)
    }
}

#if DEBUG
#Preview("Add places directly · local") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    List { TripDayAddRow(day: trip.days[0], trip: trip, controller: TripController(model: model)) }
}
#Preview("Add places and events · large text, local") {
    let model = PreviewFixtures.tripPlanner()
    let trip = model.library.trips[0]
    List { TripDayAddRow(day: trip.days[0], trip: trip, controller: TripController(model: model)) }
        .frame(width: 320).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
