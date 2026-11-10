import Observation
import SwiftUI

@MainActor @Observable final class PlacePresentationModel {
    static let compact = PresentationDetent.height(100)
    static let standard = PresentationDetent.fraction(0.5)
    private var preferredDetent = PlacePresentationModel.standard
    var usesLargeText = false
    var usesCompactHeight = false
    var allowsCompact = true

    var detents: Set<PresentationDetent> {
        if usesCompactHeight { return [.large] }
        if usesLargeText { return [.fraction(0.75), .large] }
        return allowsCompact ? [Self.compact, Self.standard, .large] : [Self.standard, .large]
    }

    var detent: PresentationDetent {
        get {
            if usesCompactHeight { return .large }
            if usesLargeText, preferredDetent != .large { return .fraction(0.75) }
            if !allowsCompact, preferredDetent == Self.compact { return Self.standard }
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

nonisolated struct PlacePanelLayout: Equatable {
    let largeText: Bool
    let compactHeight: Bool
    let allowsCompact: Bool
}
