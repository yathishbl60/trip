import SwiftUI
import TripDomain
import TripLocalization

struct TripSaveSuggestionView: View {
    let place: Place
    let trip: TripPlan
    let controller: TripController
    @State private var ranking = TripPlacementModel()

    private var input: TripPlacementInput { TripPlacementInput(tripID: trip.id, days: trip.days, place: place) }
    private var rankingController: TripPlacementController { TripPlacementController(model: ranking) }

    var body: some View {
        suggestion
            .task(id: input) { await rankingController.load(place, in: trip) }
            .onDisappear { rankingController.cancel() }
    }

    @ViewBuilder private var suggestion: some View {
        if let suggestion = ranking.result(for: input) {
            Section {
                Button {
                    controller.reviewPlacement(place, dayID: suggestion.dayID, tripID: trip.id)
                } label: {
                    Label {
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.tight) {
                            Text(suggestion.title).font(.headline)
                            Text(suggestion.reason).font(.subheadline).foregroundStyle(.secondary)
                        }
                    } icon: { Image(systemName: "mappin.and.ellipse").foregroundStyle(AppTheme.accent) }
                }.buttonStyle(.plain)
            } header: { Text(TripText.planningSuggested.resource) }
        }
    }
}

#if DEBUG
#Preview("Suggested day") {
    let model = TripPlanningPreview.fixture().0
    List { TripSaveSuggestionView(place: PreviewFixtures.unrated, trip: model.library.trips[0],
                                  controller: TripController(model: model)) }
}
#Preview("Suggested day · large text") {
    let model = TripPlanningPreview.fixture().0
    List { TripSaveSuggestionView(place: PreviewFixtures.unrated, trip: model.library.trips[0],
                                  controller: TripController(model: model)) }.dynamicTypeSize(.accessibility2)
}
#endif
