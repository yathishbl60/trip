import SwiftUI

extension AppTheme {
    /// Ordinary controls share a cadence; map cameras and direct gestures own their motion.
    enum Motion {
        static func feedback(reduceMotion: Bool) -> Animation? {
            reduceMotion ? nil : .smooth(duration: 0.2)
        }

        static func selection(reduceMotion: Bool) -> Animation? {
            reduceMotion ? nil : .smooth(duration: 0.25)
        }

        static func press(reduceMotion: Bool) -> Animation? {
            reduceMotion ? nil : .easeOut(duration: 0.16)
        }
    }
}
