#if os(iOS) || os(visionOS)
import Observation
import SwiftUI
import Foundation

@MainActor @Observable final class DirectionsPresentationModel {
    let compact: PresentationDetent
    static let standard = PresentationDetent.fraction(0.55)
    var detent = DirectionsPresentationModel.standard
    var auxiliary: DirectionsAuxiliary?
    var placePicker: DirectionsPlacePicker?
    var usesLargeText = false
    var isCompactHeight = false
    var isRegularWidth = false
    var reduceMotion = false
    @ObservationIgnored var handoffID: UUID?
    var needsRouteFraming = true
    var followsRoute = true

    init(compactHeight: CGFloat) { compact = .height(min(max(compactHeight, 100), 300)) }
    var isCompact: Bool {
        #if os(visionOS)
        false
        #else
        detent == compact && !requiresExpandedSheet
        #endif
    }
    var detents: Set<PresentationDetent> { requiresExpandedSheet ? [.large] : [compact, Self.standard, .large] }
    var requiresExpandedSheet: Bool { usesLargeText || isCompactHeight || isRegularWidth }
    var compactCornerRadius: CGFloat? { isCompact ? 32 : nil }
    var animation: Animation? { reduceMotion ? nil : .smooth(duration: 0.25) }
    var replacingPlaceID: String? {
        if case .stop(let id)? = placePicker?.target { return id }
        return nil
    }

    func reset() {
        detent = requiresExpandedSheet ? .large : Self.standard
        auxiliary = nil
        placePicker = nil
        handoffID = nil
        needsRouteFraming = true
        followsRoute = true
    }

    func accessibility(largeText: Bool, reduceMotion: Bool, compactHeight: Bool, regularWidth: Bool) {
        usesLargeText = largeText
        isCompactHeight = compactHeight
        isRegularWidth = regularWidth
        self.reduceMotion = reduceMotion
        if requiresExpandedSheet { detent = .large }
    }
}


nonisolated struct DirectionsAuxiliary: Identifiable {
    let id = UUID()
    let screen: DirectionsAuxiliaryScreen

    init(_ screen: DirectionsAuxiliaryScreen) { self.screen = screen }
}

nonisolated enum DirectionsAuxiliaryScreen { case steps, stops, options, placePicker }
#endif
