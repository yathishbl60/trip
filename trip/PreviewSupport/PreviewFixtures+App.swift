#if DEBUG
import MapEngine
extension PreviewFixtures {
    static func mapWithoutAnimations() -> ExploreModel {
        var configuration = MapConfiguration()
        configuration.motion = .init(morph: 0, fade: 0, camera: 0, selection: 0)
        let provider = LocalPlaceProvider(places: [hotel, unrated])
        return ExploreModel(configuration: configuration, provider: provider)
    }

    static func app() -> AppModel {
        AppModel(explore: explore(), trips: tripPlanner())
    }
}
#endif
