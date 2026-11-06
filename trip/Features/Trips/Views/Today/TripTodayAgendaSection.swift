import AppIntents
import SwiftUI
import TripDomain
import TripLocalization

struct TripTodayAgendaSection: View {
    let items: [TripTodayItem]
    let today: TripTodayModel
    let tripID: UUID
    let controller: TripController
    let hasOwnPane: Bool
    @Binding var isExpanded: Bool

    var body: some View {
        let title = TripText.restOfTheDayValue(TripText.number(items.count))
        if hasOwnPane {
            Section { rows } header: { Text(title.resource) }
        } else {
            Section { DisclosureGroup(title.text, isExpanded: $isExpanded) { rows } }
        }
    }

    private var rows: some View {
        ForEach(items) { item in
            Button { controller.openTodayItem(item, tripID: tripID) } label: {
                Label {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                        Text(item.title).foregroundStyle(.primary)
                        Text(today.statusText(item)).font(.caption).foregroundStyle(.secondary)
                    }
                } icon: { Image(systemName: item.isVisited ? "checkmark.circle" : item.symbol) }
                .frame(maxWidth: .infinity, minHeight: AppTheme.controlTarget, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .appEntityIdentifier(controller.detailEntityIdentifier(tripID: tripID, itemID: item.id))
        }
    }
}

#if DEBUG
#Preview("Rest of the day · single list disclosure") {
    @Previewable @State var expanded = true
    let model = TripTodayPreview.planner()
    let id = model.library.trips[0].id
    let today = model.today(id, at: TripTodayPreview.now)!
    List {
        TripTodayAgendaSection(items: today.rest, today: today, tripID: id, controller: TripController(model: model),
                               hasOwnPane: false, isExpanded: $expanded)
    }
}
#endif
