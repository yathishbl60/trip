#if !TRIP_STANDALONE
import MapEngine
#endif
import Foundation
import CoreGraphics

extension MarkerModel {
    var isFading: Bool {
        guard visibility == .retiring, let hiddenAt else { return false }
        return hiddenAt.duration(to: .now) < .seconds(motion.fade)
    }

    func retire() {
        guard isVisible else { return }
        if hasAppeared {
            reservedSize = occupiedSize
            reservationUntil = .now.advanced(by: motion.retirement)
        } else {
            clearReservation()
        }
        hiddenAt = hasAppeared ? .now : nil
        visibility = .retiring
    }

    func appear(revision: Int? = nil) {
        guard visibility == .entering,
              revision == nil || revision == presentationRevision else { return }
        visibility = .visible
    }

    var canRemove: Bool {
        guard visibility == .retiring else { return false }
        // An annotation cancelled before native appearance has nothing to fade.
        guard let hiddenAt else { return true }
        return hiddenAt.duration(to: .now) >= motion.retirement
    }
}
