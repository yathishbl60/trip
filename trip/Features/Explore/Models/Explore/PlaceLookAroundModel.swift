import TripLocalization
import MapKit
import TripDomain
import Observation

@MainActor @Observable final class PlaceLookAroundModel {
    private(set) var scene: MKLookAroundScene?
    private(set) var state: PlaceLookAroundState
    private(set) var isViewerPresented = false
    @ObservationIgnored private var request: MKLookAroundSceneRequest?
    @ObservationIgnored private var task: Task<Void, Never>?
    @ObservationIgnored private var deadline: Task<Void, Never>?
    @ObservationIgnored private var generation = 0

    init(state: PlaceLookAroundState = .idle) { self.state = state }

    func load(_ coordinate: Coordinate) {
        guard state != .loading else { return }
        cancel()
        guard coordinate.isValid else { state = .unavailable; return }
        let request = MKLookAroundSceneRequest(coordinate: coordinate.location)
        self.request = request
        let token = generation
        state = .loading
        task = Task { await resolve(request, token: token) }
        startDeadline(token: token)
    }

    private func resolve(_ request: MKLookAroundSceneRequest, token: Int) async {
        do {
            let scene = try await request.scene
            guard token == generation, !Task.isCancelled else { return }
            self.scene = scene
            state = scene == nil ? .unavailable : .available
            finish()
        } catch {
            guard token == generation, !Task.isCancelled else { return }
            fail(TripText.couldnTLoadLookAroundCheckYourConnectionAnd.text)
        }
    }

    private func startDeadline(token: Int) {
        deadline = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(20))
                guard let self, generation == token, !Task.isCancelled else { return }
                fail(TripText.lookAroundTookTooLongTryAgain.text)
            } catch { /* Completion, dismissal, or retry cancels the deadline. */ }
        }
    }

    private func fail(_ message: String) {
        cancel()
        state = .failed(message)
    }

    private func finish() {
        deadline?.cancel()
        deadline = nil
        task = nil
        request = nil
    }

    func cancel() {
        generation += 1
        request?.cancel()
        task?.cancel()
        finish()
        if state == .loading { state = .idle }
    }

    func reset() {
        cancel()
        isViewerPresented = false
        scene = nil
        state = .idle
    }

    func setViewerPresented(_ presented: Bool) {
        isViewerPresented = presented && state == .available && scene != nil
    }
}

nonisolated enum PlaceLookAroundState: Equatable {
    case idle, loading, available, unavailable
    case failed(String)
}
