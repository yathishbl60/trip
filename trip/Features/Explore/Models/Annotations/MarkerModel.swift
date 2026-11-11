#if !TRIP_STANDALONE
import TripDomain
import MapEngine
#endif
import Observation
import Foundation
import CoreGraphics

@MainActor @Observable final class MarkerModel: Identifiable {
    let id: String
    let motion: MapMotion
    private(set) var isSelected = false
    private(set) var place: Place
    private(set) var style: MarkerStyle
    private(set) var scale: CGFloat
    var visibility = MarkerVisibility.entering
    private(set) var presentationRevision = 0
    private(set) var hasPhotoContent: Bool
    private(set) var hasLabelContent: Bool
    @ObservationIgnored var hiddenAt: ContinuousClock.Instant?
    @ObservationIgnored var reservedSize = CGSize.zero
    @ObservationIgnored var reservationUntil: ContinuousClock.Instant?
    /// Layout membership includes entering artwork before the native annotation appears.
    var isVisible: Bool { visibility != .retiring }
    /// The revealed state; entering and retiring states target zero opacity.
    var hasAppeared: Bool { visibility == .visible }
    var opacity: Double { hasAppeared ? 1 : 0 }

    init(placement: MarkerPlacement, scale: CGFloat, motion: MapMotion = .init()) {
        id = placement.place.id
        self.motion = motion
        place = placement.place
        style = placement.style
        hasPhotoContent = placement.style.hasPhoto
        hasLabelContent = placement.style.hasLabel
        self.scale = scale
    }

    func update(_ placement: MarkerPlacement, scale: CGFloat, reduceMotion: Bool) {
        if !isVisible { prepareReappearance(style: placement.style, reduceMotion: reduceMotion) }
        reserveTransition(to: placement.style, scale: scale, reduceMotion: reduceMotion)
        // Mount expensive content on first use, then retain it across reverse zoom morphs.
        if placement.style.hasPhoto && !hasPhotoContent { hasPhotoContent = true }
        if placement.style.hasLabel && !hasLabelContent { hasLabelContent = true }
        if place != placement.place { place = placement.place }
        if style != placement.style { style = placement.style }
        if self.scale != scale { self.scale = scale }
        hiddenAt = nil
    }

    private func prepareReappearance(style: MarkerStyle, reduceMotion: Bool) {
        // Reverse an unfinished fade without rebuilding artwork that is still on screen.
        if !reduceMotion, isFading {
            visibility = .visible
            return
        }
        visibility = .entering
        presentationRevision += 1
        hasPhotoContent = style.hasPhoto
        hasLabelContent = style.hasLabel
        clearReservation()
    }

    func select(_ selected: Bool) {
        guard isVisible, isSelected != selected else { return }
        isSelected = selected
    }
}

nonisolated enum MarkerVisibility: Sendable {
    case entering, visible, retiring
}
