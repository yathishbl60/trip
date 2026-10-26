import Foundation
import TripDomain

extension AppModel {
    func start(isActive: Bool) async {
        navigation.isActive = isActive
        guard isActive else {
            if AppRuntime.activeScene === self { AppRuntime.activeScene = nil }
            suspendServices()
            await trips.library.flush()
            return
        }
        AppRuntime.activeScene = self
        await trips.library.load()
        guard !Task.isCancelled else { return }
        await refreshServices()
        consumeLaunch()
    }

    private func suspendServices() {
        trips.assistant.cancel()
        trips.packing.cancel()
        trips.bookingImport.cancelReading()
        trips.weather.cancel()
    }

    private func refreshServices() async {
        guard let system else { return }
        do { try await AppTripServices.systemActions.reconcileAlarms(with: trips.library.trips) }
        catch { system.error = error.localizedDescription }
        await TripJourneyRuntime.shared.refresh()
    }

    func consumeLaunch() {
        guard navigation.isActive else { return }
        guard AppRuntime.activeScene == nil || AppRuntime.activeScene === self else { return }
        guard let destination = AppLaunchModel.shared.destination else { return }
        guard trips.library.isReady else { return }
        AppLaunchModel.shared.destination = nil
        request(destination)
    }
}
