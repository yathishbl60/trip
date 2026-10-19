#if os(iOS) || os(visionOS)
import Foundation

extension DirectionsModel {
    func setMode(_ mode: TravelMode) {
        guard availableModes.contains(mode), self.mode != mode else { return }
        self.mode = mode
        refresh(debounced: true)
    }

    func setTollAvoidance(_ value: Bool) { update(\.avoidsTolls, to: value) }
    func setHighwayAvoidance(_ value: Bool) { update(\.avoidsHighways, to: value) }
    private func update(_ key: WritableKeyPath<DirectionsOptions, Bool>, to value: Bool) {
        guard options[keyPath: key] != value else { return }
        options[keyPath: key] = value
        refresh(debounced: true)
    }

    func setTiming(_ value: DirectionsTiming) {
        guard options.timing != value else { return }
        options.timing = value
        options.date = max(options.date, .now)
        refresh(debounced: true)
    }

    func setDate(_ date: Date) {
        guard options.date != date else { return }
        options.date = max(date, .now)
        refresh(debounced: true)
    }

}
#endif
