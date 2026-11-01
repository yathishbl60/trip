import TripLocalization
import SwiftUI
import TripDomain

struct TripTodayEntryView: View {
    let tripID: UUID
    let today: TripTodayModel
    let controller: TripController

    var body: some View {
        Section {
            Button { controller.openDetail(.today, tripID: tripID) } label: {
                HStack {
                    Label { VStack(alignment: .leading) {
                        Text(TripText.today.resource).font(.headline)
                        Text(today.subtitle).font(.subheadline).foregroundStyle(.secondary)
                    } } icon: { Image(systemName: "sun.max") }
                    Spacer()
                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                }.fixedSize(horizontal: false, vertical: true)
                    .frame(minHeight: AppTheme.controlTarget).contentShape(.rect)
            }.buttonStyle(.plain).accessibilityHint(TripText.openYourNextCommitmentAndTodaySItinerary.resource)
        }
    }
}

#if DEBUG
#Preview("Today entry · time zone review") {
    let model = TripTodayPreview.planner(review: true)
    let controller = TripController(model: model)
    if let today = controller.today(model.library.trips[0].id, at: TripTodayPreview.now) {
        List { TripTodayEntryView(tripID: model.library.trips[0].id, today: today, controller: controller) }
    }
}
#Preview("Today entry · narrow, large text") {
    let model = TripTodayPreview.planner()
    let controller = TripController(model: model)
    if let today = controller.today(model.library.trips[0].id, at: TripTodayPreview.now) {
        List { TripTodayEntryView(tripID: model.library.trips[0].id, today: today, controller: controller) }
            .frame(width: 320).dynamicTypeSize(.accessibility3).preferredColorScheme(.dark)
    }
}
#endif
