import TripLocalization
import SwiftUI
import AppIntents
import TripDomain

struct TripTodayNextView: View {
    let item: TripTodayItem
    let today: TripTodayModel
    let tripID: UUID
    let controller: TripController

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                heading
                savedDetails
                Button(controller.todayActionTitle(item)) {
                    controller.openTodayItem(item, tripID: tripID, directions: true)
                }
                .buttonStyle(.borderedProminent).controlSize(.large).tint(AppTheme.accentFill)
            }
            .padding(.vertical, AppTheme.Spacing.small)
            .appEntityIdentifier(controller.detailEntityIdentifier(tripID: tripID, itemID: item.id))
        } header: { Text(TripText.upNext.resource) } footer: {
            if today.leaveText(item) != nil { Text(TripText.basedOnYourManualTravelAllowanceCheckCurrentTravel.resource) }
        }
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Label(item.title, systemImage: item.symbol).font(.title2.bold()).accessibilityAddTraits(.isHeader)
            Text(today.statusText(item)).foregroundStyle(.secondary)
            if let leave = today.leaveText(item) {
                Label(leave, systemImage: "figure.walk.departure").font(.headline).foregroundStyle(AppTheme.accent)
            }
        }.fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder private var savedDetails: some View {
        switch item.item {
        case .event(let event):
            if !event.location.isEmpty { Label(event.location, systemImage: "mappin.and.ellipse") }
            if !event.notes.isEmpty { Text(event.notes).textSelection(.enabled) }
        case .visit(let stop):
            if let address = stop.place.address { Label(address, systemImage: "mappin.and.ellipse") }
            if !stop.notes.isEmpty { Text(stop.notes).textSelection(.enabled) }
        }
    }
}

#if DEBUG
#Preview("Next commitment · manual allowance") {
    let model = TripTodayPreview.planner()
    let tripID = model.library.trips[0].id
    let today = model.today(tripID, at: TripTodayPreview.now)!
    List { TripTodayNextView(item: today.next!, today: today, tripID: tripID, controller: TripController(model: model)) }
}
#Preview("Next commitment · narrow, large text") {
    let model = TripTodayPreview.planner()
    let tripID = model.library.trips[0].id
    let today = model.today(tripID, at: TripTodayPreview.now)!
    List { TripTodayNextView(item: today.next!, today: today, tripID: tripID, controller: TripController(model: model)) }
        .frame(width: 320).dynamicTypeSize(.accessibility3).preferredColorScheme(.dark)
}
#endif
