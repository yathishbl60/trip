import AppIntents
import TripDomain
import WidgetKit
import Foundation

@MainActor final class AppSystemModel {
    private var generation = 0
    private let spotlight = TripSpotlightModel()
    var error: String?

    func publish(_ plans: [TripPlan]) async {
        generation += 1
        let token = generation
        let snapshots = plans.map(TripSurfacePlan.init)
        let alarmError = await reconcileAlarms(plans)
        do {
            try await TripSystemData.publish(snapshots, at: .now)
            guard token == generation else { return }
            reloadSurfaces()
            await spotlight.publish(snapshots)
            await TripJourneyRuntime.shared.refresh()
            if token == generation { error = alarmError }
        } catch {
            if token == generation { self.error = error.localizedDescription }
        }
    }

    private func reconcileAlarms(_ plans: [TripPlan]) async -> String? {
        do { try await AppTripServices.systemActions.reconcileAlarms(with: plans); return nil }
        catch { return error.localizedDescription }
    }

    private func reloadSurfaces() {
        WidgetCenter.shared.reloadTimelines(ofKind: TripSystemData.widgetKind)
        WidgetCenter.shared.reloadTimelines(ofKind: TripSystemData.readinessWidgetKind)
        TripDaySnippetIntent.reload()
        TripNextStepSnippetIntent.reload()
        TripAnswerSnippetIntent.reload()
        TripChecklistSnippetIntent.reload()
        TripShortcuts.updateAppShortcutParameters()
        #if os(iOS)
        ControlCenter.shared.reloadControls(ofKind: TripSystemData.controlKind)
        #endif
    }

}
