import TripDomain
import SwiftUI

struct TripDayHeaderView: View {
    let day: TripDay
    let trip: TripPlan
    let controller: TripController
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: AppTheme.Spacing.tight))
            : AnyLayout(HStackLayout(alignment: .top, spacing: AppTheme.Spacing.small))
        return layout {
            heading.layoutPriority(1)
            if !typeSize.isAccessibilitySize { Spacer(minLength: AppTheme.Spacing.small) }
            TripDayActionsMenu(day: day, trip: trip, controller: controller)
                .fixedSize()
        }
        .textCase(nil)
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
            Text(day.title).font(.headline).foregroundStyle(.primary)
            Text("\(trip.dateText(for: day)) · \(trip.journeySummary(on: day))")
                .font(.subheadline).foregroundStyle(.secondary)
        }.fixedSize(horizontal: false, vertical: true)
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
