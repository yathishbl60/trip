import TripLocalization
import Observation
import TripDomain
import Foundation

@MainActor @Observable final class TripTrackingModel {
    let runtime: TripJourneyRuntime?
    var error: String?
    private var isWorking = false
    @ObservationIgnored var prepare: @MainActor () async throws -> Void = {}
    @ObservationIgnored private var task: Task<Void, Never>?
    var isAvailable: Bool { runtime != nil }
    var isBusy: Bool { isWorking || runtime?.isBusy == true }
    var explanation: String {
        #if os(visionOS)
        TripText.keepTrackOfYourNextPlaceAndVisitsIn.text
        #else
        TripText.keepYourNextPlaceOnTheLockScreenAnd.text
        #endif
    }

    init(runtime: TripJourneyRuntime? = nil) { self.runtime = runtime }

    func start(_ trip: TripPlan, dayID: UUID) {
        guard let runtime else { return }
        run {
            try await self.prepare()
            try await runtime.start(tripID: trip.id, dayID: dayID)
        }
    }

    func visit() {
        guard let runtime, let day = runtime.day, let journey = runtime.journey,
              let stop = journey.nextStop(in: day) else { return }
        run { try await runtime.advance(expectedStopID: stop.id, tripID: journey.tripID, dayID: day.id) }
    }

    func undo() {
        guard let runtime else { return }
        run { try await runtime.undo() }
    }

    func end() {
        guard let runtime else { return }
        run { try await runtime.end() }
    }

    private func run(_ action: @escaping @MainActor () async throws -> Void) {
        guard !isBusy else { return }
        error = nil
        isWorking = true
        task = Task {
            defer { task = nil; isWorking = false }
            do { try await action() }
            catch { self.error = error.localizedDescription }
        }
    }
}
