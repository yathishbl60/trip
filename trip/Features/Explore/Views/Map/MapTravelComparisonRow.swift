import SwiftUI
import TripDomain
import TripRouting
import TripLocalization

struct MapTravelComparisonRow: View {
    let place: Place
    let controller: MapTravelController
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var selected: Bool { controller.model.selected.contains(place.id) }

    var body: some View {
        Button { controller.toggle(place) } label: {
            HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
                selectionSymbol
                VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                    Text(place.name).font(.headline).foregroundStyle(.primary)
                    Text(place.address ?? place.category.title).font(.subheadline).foregroundStyle(.secondary)
                    estimate
                }
            }.frame(maxWidth: .infinity, alignment: .leading).contentShape(.rect)
        }
        .buttonStyle(.plain).disabled(!selected && controller.model.selected.count >= 3)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var selectionSymbol: some View {
        Image(systemName: selected ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(selected ? AppTheme.accent : .secondary)
            .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
            .accessibilityHidden(true)
    }

    @ViewBuilder private var estimate: some View {
        if selected, let estimate = controller.model.estimates[place.id] {
            Text("\(estimate.durationText) · \(estimate.distanceText)").foregroundStyle(.primary)
        } else if selected, controller.model.failures.contains(place.id) {
            Text(TripText.estimateUnavailable.resource).foregroundStyle(.secondary)
        }
    }
}

#if DEBUG
#Preview("Comparison place · long content") {
    List {
        MapTravelComparisonRow(place: PreviewFixtures.longName,
            controller: MapTravelController(model: MapTravelComparisonModel(places: [PreviewFixtures.longName], groups: [])))
    }.dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
