import TripLocalization
import SwiftUI
import TripDomain

struct TripMapDayHeader: View {
    let day: TripDay
    let trip: TripPlan
    let controller: TripController
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            actions
            if let issue = controller.model.dayDirectionsIssue(day, tripID: trip.id) {
                Text(issue).font(.footnote).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(AppTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.bar)
        .overlay(alignment: .bottom) { Divider() }
    }

    private var actions: some View {
        let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout(spacing: AppTheme.Spacing.medium))
        return layout {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                Text(day.title).font(.headline)
                Text(trip.dateText(for: day)).font(.subheadline).foregroundStyle(.secondary)
            }.frame(maxWidth: .infinity, alignment: .leading)
            Button(TripText.directions.resource, systemImage: "arrow.triangle.turn.up.right.diamond") {
                controller.showDirections(dayID: day.id, tripID: trip.id)
            }
            .buttonStyle(.bordered).buttonSizing(.fitted).controlSize(.regular)
            .disabled(controller.model.dayDirectionsIssue(day, tripID: trip.id) != nil)
            .accessibilityLabel(TripText.directionsForValue(day.title).resource)
        }
    }
}

#if DEBUG
#Preview("Day directions · local") {
    let model = TripMapPreview.planner()
    let trip = model.library.trips[0]
    TripMapDayHeader(day: trip.days[0], trip: trip, controller: TripController(model: model))
}
#Preview("Day directions · narrow, accessibility") {
    let model = TripMapPreview.planner()
    let trip = model.library.trips[0]
    TripMapDayHeader(day: trip.days[0], trip: trip, controller: TripController(model: model))
        .frame(width: 320).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
