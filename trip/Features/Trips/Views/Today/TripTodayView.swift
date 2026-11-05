import TripLocalization
import SwiftUI
import AppIntents
import TripDomain

struct TripTodayView: View {
    let tripID: UUID
    let controller: TripController
    var previewDate: Date? = nil

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            if let today = controller.today(tripID, at: previewDate ?? context.date) { content(today) }
            else { ContentUnavailableView(TripText.tripUnavailable.resource, systemImage: "suitcase.rolling") }
        }
        .navigationTitle(TripText.today.resource).navigationBarTitleDisplayMode(.inline)
        .tripWayfinding(.today, tripID: tripID, controller: controller)
        #if os(iOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        #endif
    }

    private func content(_ today: TripTodayModel) -> some View {
        List {
            if today.snapshot.needsTimeZoneReview { review }
            else if let next = today.next {
                TripTodayNextView(item: next, today: today, tripID: tripID, controller: controller)
            } else { ContentUnavailableView(today.emptyTitle, systemImage: "sun.horizon", description: Text(today.emptyMessage)) }
            if !today.rest.isEmpty { rest(today) }
            Section { Text(today.zoneText).font(.footnote).foregroundStyle(.secondary) }
        }
    }

    private var review: some View {
        Section {
            Label(TripText.confirmThisTripSTimeZone.resource, systemImage: "clock.badge.questionmark")
            Text(TripText.olderSchedulesNeedYourReviewBeforeTodayCanUse.resource).foregroundStyle(.secondary)
            Button(TripText.reviewInEditTrip.resource) { controller.beginEdit(tripID) }
        }
    }

    private func rest(_ today: TripTodayModel) -> some View {
        Section {
            DisclosureGroup(TripText.restOfTheDayValue(TripText.number(today.rest.count)).text) {
                ForEach(today.rest) { item in
                    Button { controller.openTodayItem(item, tripID: tripID) } label: {
                        Label { VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                            Text(item.title).foregroundStyle(.primary)
                            Text(today.statusText(item)).font(.caption).foregroundStyle(.secondary)
                        } } icon: { Image(systemName: item.isVisited ? "checkmark.circle" : item.symbol) }
                            .frame(maxWidth: .infinity, minHeight: AppTheme.controlTarget, alignment: .leading)
                            .contentShape(.rect)
                    }.buttonStyle(.plain)
                        .appEntityIdentifier(controller.detailEntityIdentifier(tripID: tripID, itemID: item.id))
                }
            }
        }
    }
}

#if DEBUG
#Preview("Today · saved plans") {
    let model = TripTodayPreview.planner()
    NavigationStack { TripTodayView(tripID: model.library.trips[0].id, controller: TripController(model: model),
                                   previewDate: TripTodayPreview.now) }
}
#Preview("Today · review · accessibility · dark") {
    let model = TripTodayPreview.planner(review: true)
    NavigationStack { TripTodayView(tripID: model.library.trips[0].id, controller: TripController(model: model),
                                   previewDate: TripTodayPreview.now) }
    .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Today · no scheduled day") {
    let model = TripTodayPreview.planner()
    NavigationStack { TripTodayView(tripID: model.library.trips[0].id, controller: TripController(model: model),
                                   previewDate: TripTodayPreview.now.addingTimeInterval(-86400)) }
}
#Preview("Today · large text, local itinerary") {
    let model = TripTodayPreview.planner()
    NavigationStack { TripTodayView(tripID: model.library.trips[0].id, controller: TripController(model: model),
                                   previewDate: TripTodayPreview.now) }
        .frame(width: 320).dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
