import SwiftUI
import TripLocalization

struct TripWeatherView: View {
    let model: TripWeatherModel
    let onReviewSchedule: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    private var controller: TripWeatherController { TripWeatherController(model: model) }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(TripText.weatherForDay.resource)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
        }
        .task(id: scenePhase == .active ? model.revision : nil) {
            if scenePhase == .active { await controller.load() }
        }
        .onDisappear(perform: controller.cancel)
    }

    private var content: some View {
        List {
            Section { status } header: { Text(model.title) }
            ForEach(model.visits) { visit in
                TripWeatherVisitRow(visit: visit, timeZone: model.timeZone)
            }
            Section {
                Button(TripText.weatherReviewSchedule.resource, systemImage: "calendar.badge.clock", action: onReviewSchedule)
                if let message = model.omissionsMessage { Text(message).font(.footnote).foregroundStyle(.secondary) }
            }
            if let attribution = model.attribution {
                TripWeatherAttributionView(attribution: attribution, issuedAt: model.issuedAt,
                                           coverage: model.coverage, timeZone: model.timeZone)
            }
        }
    }

    @ViewBuilder private var status: some View {
        if model.isLoading { ProgressView(TripText.weatherLoading.resource) }
        if let issue = model.availabilityIssue {
            Label(issue, systemImage: "cloud.slash").foregroundStyle(.secondary)
        } else if model.needsSchedule {
            Label(model.emptyMessage, systemImage: "clock.badge.questionmark")
        } else if model.hasFailures {
            Text(TripText.weatherLoadFailure.resource).foregroundStyle(.secondary)
        } else {
            Text(TripText.weatherForecastScope.resource).font(.footnote).foregroundStyle(.secondary)
        }
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) { Button(TripText.done.resource) { dismiss() } }
        ToolbarItem(placement: .primaryAction) {
            Button(TripText.weatherRefresh.resource, systemImage: "arrow.clockwise", action: controller.retry)
                .disabled(!model.canRefresh)
        }
    }
}

#if DEBUG
#Preview("Day weather · local forecast") {
    TripWeatherView(model: TripWeatherPreview.model(), onReviewSchedule: {})
}
#Preview("Day weather · large text and dark") {
    TripWeatherView(model: TripWeatherPreview.model(), onReviewSchedule: {})
        .dynamicTypeSize(.accessibility2).preferredColorScheme(.dark)
}
#Preview("Day weather · service unavailable") {
    TripWeatherView(model: TripWeatherPreview.model(fails: true), onReviewSchedule: {})
}
#Preview("Day weather · unavailable build") {
    TripWeatherView(model: TripWeatherPreview.model(availabilityIssue: TripText.weatherNotEnabledInBuild.text),
                    onReviewSchedule: {})
}
#endif
