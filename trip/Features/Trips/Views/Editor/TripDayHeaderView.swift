import TripDomain
import SwiftUI

struct TripDayHeaderView: View {
    let day: TripDay
    let trip: TripPlan
    let controller: TripController

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                Text(day.title).font(.headline).foregroundStyle(.primary).fixedSize(horizontal: false, vertical: true)
                Text("\(trip.dateText(for: day)) · \(trip.journeySummary(on: day))")
                    .font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            .layoutPriority(1)
            Spacer()
            TripDayActionsMenu(day: day, trip: trip, controller: controller)
                .fixedSize()
        }
        .textCase(nil)
    }
}

#if DEBUG
#Preview("Itinerary day", traits: .sizeThatFitsLayout) {
    let model = PreviewFixtures.tripPlanner()
    TripDayHeaderView(day: model.library.trips[0].days[0], trip: model.library.trips[0],
                      controller: TripController(model: model)).padding()
}
#Preview("Another day · dark", traits: .sizeThatFitsLayout) {
    let model = PreviewFixtures.tripPlanner()
    TripDayHeaderView(day: model.library.trips[0].days[1], trip: model.library.trips[0],
                      controller: TripController(model: model))
        .padding().preferredColorScheme(.dark)
}
#Preview("Day heading · narrow, large text") {
    let model = PreviewFixtures.tripPlanner()
    List {
        Section {} header: {
            TripDayHeaderView(day: model.library.trips[0].days[0], trip: model.library.trips[0],
                              controller: TripController(model: model))
        }
    }.frame(width: 320).dynamicTypeSize(.accessibility3)
}
#endif
