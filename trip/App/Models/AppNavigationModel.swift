import Observation
import Foundation

nonisolated enum AppTab: String, Hashable { case explore, trips }

@MainActor @Observable final class AppNavigationModel {
    let id = UUID()
    var tab = AppTab.trips
    var isActive = false
    var didRestore = false
    var notice: String?
    @ObservationIgnored private(set) var generation = 0
    @ObservationIgnored private var activationRevision = 0
    @ObservationIgnored var requestTask: Task<Void, Never>?

    func beginActivation(_ isActive: Bool) -> Int {
        activationRevision += 1
        self.isActive = isActive
        return activationRevision
    }

    func acceptsActivation(_ revision: Int) -> Bool {
        isActive && activationRevision == revision && !Task.isCancelled
    }

    @discardableResult func beginRequest() -> Int {
        generation += 1
        didRestore = true
        requestTask?.cancel()
        requestTask = nil
        return generation
    }

    func accepts(_ generation: Int) -> Bool { self.generation == generation && !Task.isCancelled }
}

@MainActor @Observable final class AppLaunchModel {
    static let shared = AppLaunchModel()
    private(set) var pending: AppRequest?
    private(set) var revision = 0

    /// Foreground requests coalesce while no eligible scene is ready to receive them.
    func open(_ request: AppRequest) {
        pending = request
        revision += 1
    }

    func consume(sceneID: UUID, preferredSceneID: UUID?) -> AppRequest? {
        guard preferredSceneID == nil || preferredSceneID == sceneID else { return nil }
        defer { pending = nil }
        return pending
    }
}
