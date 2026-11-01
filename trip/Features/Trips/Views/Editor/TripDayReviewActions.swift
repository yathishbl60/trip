import SwiftUI
import TripDomain
import TripLocalization

struct TripDayReviewActions: View {
    let day: TripDay
    let trip: TripPlan
    let controller: TripController

    var body: some View {
        Button(TripText.planningPreview.resource, systemImage: "list.bullet.below.rectangle") {
            controller.beginPlanning(dayID: day.id, tripID: trip.id)
        }
        Button(TripText.suggestStopOrder.resource, systemImage: "list.number") {
            controller.beginStopOrder(dayID: day.id, tripID: trip.id)
        }.disabled(controller.model.stopOrderIssue(day: day, tripID: trip.id) != nil)
    }
}

#if DEBUG
#Preview("Day review menu") {
    let model = TripPlanningPreview.fixture().0
    let trip = model.library.trips[0]
    Menu("Day") { TripDayReviewActions(day: trip.days[0], trip: trip, controller: TripController(model: model)) }
}
#endif
