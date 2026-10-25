import TripLocalization
#if os(iOS)
import ActivityKit
#endif
import Observation
import TripDomain
import TripStorage
import WidgetKit
import Foundation

@MainActor @Observable final class TripJourneyRuntime {
    static let shared = TripJourneyRuntime()
    var journey: TripJourney?
    var day: TripSurfaceDay?
    var isBusy = false
    @ObservationIgnored var needsRefresh = false
    @ObservationIgnored var onChange: (@MainActor () -> Void)?

    func start(tripID: UUID, dayID: UUID) async throws {
        guard !isBusy else { throw TripJourneyError.busy }
        isBusy = true
        defer { finish() }
        #if os(iOS)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { throw TripJourneyError.disabled }
        #endif
        guard let plan = try await TripSystemData.store.plan(tripID) else { throw TripSurfaceError.missingTrip }
        guard let day = plan.days.first(where: { $0.id == dayID }), !day.stops.isEmpty else {
            throw TripSurfaceError.missingDay
        }
        try await begin(plan: plan, day: day)
    }

    func advance(expectedStopID: UUID? = nil, tripID: UUID? = nil, dayID: UUID? = nil) async throws {
        guard !isBusy else { throw TripJourneyError.busy }
        isBusy = true
        defer { finish() }
        journey = try await TripSystemData.store.advance(expectedStopID: expectedStopID, tripID: tripID, dayID: dayID)
        try await updateActivities()
    }

    func undo() async throws {
        guard !isBusy else { throw TripJourneyError.busy }
        isBusy = true
        defer { finish() }
        journey = try await TripSystemData.store.undoVisit()
        try await restoreAfterUndo()
    }

    func end() async throws {
        guard !isBusy else { throw TripJourneyError.busy }
        isBusy = true
        defer { finish() }
        journey = try await TripSystemData.store.endJourney()
        try await updateActivities()
    }

    func finish() {
        isBusy = false
        WidgetCenter.shared.reloadTimelines(ofKind: TripSystemData.widgetKind)
        onChange?()
        if needsRefresh {
            needsRefresh = false
            Task { await refresh() }
        }
    }
}

nonisolated enum TripJourneyError: LocalizedError {
    case busy, disabled

    var errorDescription: String? {
        switch self {
        case .busy: TripText.tripIsUpdatingTryAgainInAMoment.text
        case .disabled: TripText.allowLiveActivitiesForTripInSettingsToTrack.text
        }
    }
}
