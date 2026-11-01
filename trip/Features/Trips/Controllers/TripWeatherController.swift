import SwiftUI

@MainActor struct TripWeatherController {
    let model: TripWeatherModel

    func load() async { await model.load() }
    func retry() { model.retry() }
    func cancel() { model.cancel() }

    func sceneChanged(_ phase: ScenePhase) {
        if phase == .active { model.retry() }
        else { model.cancel() }
    }
}
