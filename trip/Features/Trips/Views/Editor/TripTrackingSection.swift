import TripLocalization
import TripDomain
import SwiftUI

struct TripTrackingSection: View {
    let trip: TripPlan
    let controller: TripController
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ViewBuilder var body: some View {
        if controller.model.tracking.runtime?.journey?.tripID == trip.id || controller.model.tracking.error != nil {
            Section {
                if let runtime = controller.model.tracking.runtime,
                   let journey = runtime.journey, journey.tripID == trip.id, let day = runtime.day {
                    progress(journey, day: day)
                }
                if let error = controller.model.tracking.error { Text(error).foregroundStyle(.secondary) }
            } header: { Text(TripText.dayProgress.resource) }
            .disabled(controller.model.tracking.isBusy)
        }
    }

    private func progress(_ journey: TripJourney, day: TripSurfaceDay) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            ProgressView(value: Double(journey.visited.count), total: Double(max(day.stops.count, 1))) {
                Text(TripText.dayValueValueOfValueVisited(TripText.number(day.number), TripText.number(journey.visited.count), TripText.number(day.stops.count)).resource).font(.headline)
            }
            .animation(reduceMotion ? nil : .smooth(duration: 0.25), value: journey.visited.count)
            if let stop = journey.nextStop(in: day), journey.isActive {
                Label(stop.name, systemImage: "mappin.and.ellipse").font(.title3.weight(.semibold))
                    .contentTransition(.opacity)
                    .animation(reduceMotion ? nil : .smooth(duration: 0.2), value: stop.id)
                Button(TripText.markVisited2.resource, systemImage: "checkmark.circle", action: controller.visitNextStop)
                    .buttonStyle(.borderedProminent).tint(AppTheme.accentFill)
            } else { Text(journey.visited.count == day.stops.count ? TripText.allPlacesVisited.text : TripText.trackingEnded.text) }
            controls(for: journey).buttonStyle(.borderless)
        }.padding(.vertical, AppTheme.Spacing.tight)
    }

    @ViewBuilder private func controls(for journey: TripJourney) -> some View {
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                undoButton(for: journey)
                endButton(for: journey)
            }.font(.subheadline)
        } else {
            HStack {
                undoButton(for: journey)
                Spacer()
                endButton(for: journey)
            }.font(.subheadline)
        }
    }

    @ViewBuilder private func undoButton(for journey: TripJourney) -> some View {
        Button(TripText.undoLastVisit.resource, action: controller.undoVisit).disabled(journey.visited.isEmpty)
    }

    @ViewBuilder private func endButton(for journey: TripJourney) -> some View {
        if journey.isActive { Button(TripText.endTracking2.resource, action: controller.endTracking) }
    }
}

#if DEBUG
#Preview("Track a saved day · local data") {
    let fixture = PreviewFixtures.tripPlanner()
    let model = PreviewTripServices.makeTrips(fixture.library.trips, tracking: TripTrackingModel(runtime: TripJourneyRuntime()))
    return List { TripTrackingSection(trip: model.library.trips[0], controller: TripController(model: model)) }
}
#Preview("Active day · dark") {
    let fixture = PreviewFixtures.tripPlanner()
    let trip = fixture.library.trips[0]
    let runtime = TripJourneyRuntime()
    runtime.journey = TripJourney(tripID: trip.id, dayID: trip.days[0].id)
    runtime.day = TripSurfaceDay(trip.days[0], date: trip.startDate)
    let model = PreviewTripServices.makeTrips(fixture.library.trips, tracking: TripTrackingModel(runtime: runtime))
    return List { TripTrackingSection(trip: trip, controller: TripController(model: model)) }.preferredColorScheme(.dark)
}
#endif
