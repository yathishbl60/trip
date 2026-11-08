#if os(iOS) || os(visionOS)
import Observation
import SwiftUI
import Foundation

@MainActor @Observable final class DirectionsPresentationModel {
    let compact: PresentationDetent
    static let standard = PresentationDetent.fraction(0.55)
    private var preferredDetent = DirectionsPresentationModel.standard
    private(set) var session = 0
    var stepsVisit: UUID?
    var auxiliary: DirectionsAuxiliary?
    var placePicker: DirectionsPlacePicker?
    var usesLargeText = false
    var reduceMotion = false
    @ObservationIgnored var handoffID: UUID?
    var needsRouteFraming = true
    var followsRoute = true

    init(compactHeight: CGFloat) { compact = .height(min(max(compactHeight, 100), 300)) }

    var detents: Set<PresentationDetent> { usesLargeText ? [Self.standard, .large] : [compact, Self.standard, .large] }

    var detent: PresentationDetent {
        get { usesLargeText && preferredDetent == compact ? Self.standard : preferredDetent }
        set {
            guard newValue != detent, detents.contains(newValue) else { return }
            preferredDetent = newValue
        }
    }

    var isCompact: Bool {
        #if os(visionOS)
        false
        #else
        detent == compact
        #endif
    }
    var animation: Animation? { reduceMotion ? nil : .smooth(duration: 0.25) }
    var replacingPlaceID: String? {
        if case .stop(let id)? = placePicker?.target { return id }
        return nil
    }

    func reset() {
        session += 1
        preferredDetent = Self.standard
        stepsVisit = nil
        auxiliary = nil
        placePicker = nil
        handoffID = nil
        needsRouteFraming = true
        followsRoute = true
    }
}

nonisolated struct DirectionsAuxiliary: Identifiable {
    let id = UUID()
    let screen: DirectionsAuxiliaryScreen

    init(_ screen: DirectionsAuxiliaryScreen) { self.screen = screen }
}

nonisolated enum DirectionsAuxiliaryScreen { case stops, options, placePicker }
#endif
