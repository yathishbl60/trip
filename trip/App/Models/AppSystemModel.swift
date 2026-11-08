import AppIntents
import TripDomain
import WidgetKit
import Foundation

@MainActor final class AppSystemModel {
    private var generation = 0
    private var refreshRevision = 0
    private let spotlight = TripSpotlightModel()
    private let systemActions: any TripSystemActionProviding
    private let journey: TripJourneyRuntime
    var error: String?

    init(systemActions: any TripSystemActionProviding, journey: TripJourneyRuntime) {
        self.systemActions = systemActions
        self.journey = journey
    }

    func recordTripOpened(_ trip: TripPlan) {
        let entity = SavedTripEntity(TripSurfaceSummary(TripSurfacePlan(trip)))
        IntentDonationManager.shared.donate(intent: OpenSavedTripIntent(trip: entity))
    }

    func publish(_ plans: [TripPlan]) async {
        generation += 1
        let token = generation
        let snapshots = plans.map(TripSurfacePlan.init)
        let alarmError = await reconcileAlarms(plans)
        guard token == generation else { return }
        do {
            try await TripSystemData.publish(snapshots, at: .now)
            guard token == generation else { return }
            reloadSurfaces()
            await spotlight.publish(snapshots)
            await journey.refresh()
            if token == generation { error = alarmError }
        } catch {
            if token == generation { self.error = error.localizedDescription }
        }
    }

    func refresh(_ plans: [TripPlan]) async {
        refreshRevision += 1
        let revision = refreshRevision
        let publication = generation
        let alarmError = await reconcileAlarms(plans)
        guard !Task.isCancelled, revision == refreshRevision, publication == generation else { return }
        if let alarmError { error = alarmError }
        await journey.refresh()
    }

    private func reconcileAlarms(_ plans: [TripPlan]) async -> String? {
        do { try await systemActions.reconcileAlarms(with: plans); return nil }
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
