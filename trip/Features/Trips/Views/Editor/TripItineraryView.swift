import TripLocalization
import Foundation
import SwiftUI
import TripDomain

struct TripItineraryView: View {
    let trip: TripPlan
    let controller: TripController
    let now: Date

    var body: some View {
        List {
            TripOverviewView(trip: trip)
            if let today = controller.today(trip.id, at: now), today.showsEntry {
                TripTodayEntryView(tripID: trip.id, today: today, controller: controller)
            }
            notice
            TripTrackingSection(trip: trip, controller: controller)
            days
            planningActions
        }
        .reorderContainer(for: TripJourneyItem.self, in: TripJourneyReorderGroupID.self,
                          isEnabled: controller.model.canReorderStops(in: trip.id)) {
            controller.reorderStops($0, in: trip)
        }
        #if os(iOS)
        .scrollDismissesKeyboard(.interactively)
        #endif
    }

    @ViewBuilder private var notice: some View {
        if let notice = controller.model.presentation.notice {
            Section { Label(notice, systemImage: "info.circle").foregroundStyle(.secondary) }
        }
    }

    private var days: some View {
        ForEach(trip.days) { day in
            TripDaySection(day: day, trip: trip, controller: controller)
        }
    }

    private var planningActions: some View {
        Section {
            Button(TripText.addDay.resource, systemImage: "plus.circle") { controller.addDay(to: trip.id) }
                .disabled(trip.days.count >= TripLimits.days)
        }
    }
}

#if DEBUG
#Preview("Populated itinerary · no preview card, local") {
    let model = PreviewFixtures.tripPlanner()
    NavigationStack {
        TripItineraryView(trip: model.library.trips[0], controller: TripController(model: model), now: TripLayoutPreview.now)
    }
}
#Preview("Screenshot regression · empty future trip, local") {
    let model = TripLayoutPreview.emptyPlanner()
    NavigationStack {
        TripItineraryView(trip: model.library.trips[0], controller: TripController(model: model), now: TripLayoutPreview.now)
            .navigationTitle("Test")
    }.frame(width: 393, height: 852).preferredColorScheme(.dark)
}
#Preview("Empty future trip · accessibility, local") {
    let model = TripLayoutPreview.emptyPlanner()
    NavigationStack {
        TripItineraryView(trip: model.library.trips[0], controller: TripController(model: model), now: TripLayoutPreview.now)
    }.frame(width: 320, height: 640).dynamicTypeSize(.accessibility2)
}
#Preview("Today entry and itinerary · local data") {
    let model = TripTodayPreview.planner()
    NavigationStack {
        TripItineraryView(trip: model.library.trips[0], controller: TripController(model: model), now: TripTodayPreview.now)
    }
}
#Preview("Drag between days · mixed bookings, local") {
    let model = TripJourneyPreview.planner()
    NavigationStack {
        TripItineraryView(trip: model.library.trips[0], controller: TripController(model: model), now: TripLayoutPreview.now)
    }
}
#Preview("Cross-day drag · compact, dark") {
    let model = TripSchedulePreview.planner(overloaded: true)
    NavigationStack {
        TripItineraryView(trip: model.library.trips[0], controller: TripController(model: model), now: TripLayoutPreview.now)
    }.frame(width: 320).preferredColorScheme(.dark)
}
#endif
