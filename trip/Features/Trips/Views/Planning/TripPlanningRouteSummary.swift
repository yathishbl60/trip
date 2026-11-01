import SwiftUI
import TripRouting
import TripDomain
import TripLocalization

struct TripPlanningRouteSummary: View {
    let draft: TripPlanningDraft
    let controller: TripController

    var body: some View {
        Section {
            Picker(TripText.directions.resource, selection: controller.planningMode(draft)) {
                ForEach([TravelMode.walking, .driving, .cycling]) { mode in
                    Label(mode.title, systemImage: mode.symbol).tag(mode)
                }
            }
            status
            if draft.routes.hasMissingRoutes, !draft.routes.isLoading {
                Text(TripText.planningRouteMissing.resource).font(.footnote).foregroundStyle(.secondary)
            }
            if draft.missingLocations {
                Label(TripText.planningUnavailableLocation.resource, systemImage: "mappin.slash").font(.footnote)
            }
        }
    }

    @ViewBuilder private var status: some View {
        HStack {
            Button(TripText.planningRefreshRoutes.resource, systemImage: "arrow.clockwise") {
                controller.retryPlanning(draft)
            }
            .disabled(draft.routes.isLoading || draft.day.stops.count < 2)
            Spacer(minLength: AppTheme.Spacing.small)
            if draft.routes.isLoading {
                ProgressView().accessibilityLabel(TripText.planningRouteUpdating.resource)
            }
        }
        if let minutes = draft.routes.totalMinutes {
            Label(TripText.planningRouteTotal(TripScheduleText.duration(minutes)).resource,
                  systemImage: draft.routes.mode.symbol).contentTransition(.numericText())
        }
    }
}

#if DEBUG
#Preview("Route estimates · offline fixture") {
    let (model, draft) = TripPlanningPreview.fixture()
    List { TripPlanningRouteSummary(draft: draft, controller: TripController(model: model)) }
}
#Preview("Route choices · large text") {
    let (model, draft) = TripPlanningPreview.fixture()
    List { TripPlanningRouteSummary(draft: draft, controller: TripController(model: model)) }
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#endif
