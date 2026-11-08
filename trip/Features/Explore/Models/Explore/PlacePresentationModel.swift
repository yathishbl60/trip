import Observation
import SwiftUI

@MainActor @Observable final class PlacePresentationModel {
    static let compact = PresentationDetent.height(100)
    static let standard = PresentationDetent.fraction(0.5)
    private var preferredDetent = PlacePresentationModel.standard
    var usesLargeText = false

    var detents: Set<PresentationDetent> {
        usesLargeText ? [.fraction(0.75), .large] : [Self.compact, Self.standard, .large]
    }

    var detent: PresentationDetent {
        get {
            if usesLargeText, preferredDetent != .large { return .fraction(0.75) }
            return preferredDetent
        }
        set {
            guard newValue != detent, detents.contains(newValue) else { return }
            preferredDetent = newValue == .fraction(0.75) ? Self.standard : newValue
        }
    }

    var isCompact: Bool {
        #if os(iOS)
        detent == Self.compact
        #else
        false
        #endif
    }

    func expandIfCompact() {
        if preferredDetent == Self.compact { preferredDetent = Self.standard }
    }

    func reset() { preferredDetent = Self.standard }
}
