import Foundation
import TripDomain

extension AppModel {
    func start(isActive: Bool, tab: String, tripID: String, initialTripID: UUID?) async {
        guard !Task.isCancelled else { return }
        let activation = navigation.beginActivation(isActive)
        let publication = system?.publicationRevision
        guard isActive else {
            if AppRuntime.activeScene === self { AppRuntime.activeScene = nil }
            trips.suspendHostServices()
            await trips.library.flush()
            return
        }
        AppRuntime.activeScene = self
        await restore(tab: tab, tripID: tripID, initialTripID: initialTripID)
        guard navigation.acceptsActivation(activation) else { return }
        await trips.library.load()
        guard navigation.acceptsActivation(activation), trips.library.isReady else { return }
        await system?.refresh(trips.library.trips, since: publication)
        guard navigation.acceptsActivation(activation) else { return }
        consumeLaunch()
    }

    func consumeLaunch(from mailbox: AppLaunchModel = .shared, preferredSceneID: UUID? = AppRuntime.activeScene?.navigation.id) {
        guard navigation.isActive, trips.library.isReady else { return }
        guard let request = mailbox.consume(sceneID: navigation.id, preferredSceneID: preferredSceneID) else { return }
        self.request(request)
    }
}
