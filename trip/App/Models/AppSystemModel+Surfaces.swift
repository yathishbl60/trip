import AppIntents
import Foundation
import TripDomain
import WidgetKit

extension AppSystemModel {
    func recordTripOpened(_ trip: TripPlan) {
        let entity = SavedTripEntity(TripSurfaceSummary(TripSurfacePlan(trip)))
        IntentDonationManager.shared.donate(intent: OpenSavedTripIntent(trip: entity))
    }

    func reloadSurfaces() {
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
