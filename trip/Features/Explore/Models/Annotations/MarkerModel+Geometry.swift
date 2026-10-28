#if !TRIP_STANDALONE
import MapEngine
#endif
import Foundation
import CoreGraphics

extension MarkerModel {
    var hasActiveReservation: Bool {
        guard let reservationUntil else { return false }
        return .now < reservationUntil
    }

    var occupiedSize: CGSize {
        let size = style.hitSize(scale: scale)
        guard hasActiveReservation else { return size }
        return CGSize(width: max(size.width, reservedSize.width), height: max(size.height, reservedSize.height))
    }

    func reserveTransition(to nextStyle: MarkerStyle, scale nextScale: CGFloat, reduceMotion: Bool) {
        guard !reduceMotion, hasAppeared else {
            clearReservation()
            return
        }
        guard style != nextStyle || scale != nextScale else { return }
        // Capture the occupied envelope before changing style, including a reversed morph.
        reservedSize = occupiedSize
        reservationUntil = .now.advanced(by: motion.reservation)
    }

    func clearReservation() {
        reservedSize = .zero
        reservationUntil = nil
    }

    func reservation(at point: CGPoint) -> MarkerReservation {
        let size = occupiedSize
        let clearance = MarkerLayoutPolicy.steadyClearance
        let rect = CGRect(x: point.x - size.width / 2, y: point.y - size.height / 2,
                          width: size.width, height: size.height).insetBy(dx: -clearance, dy: -clearance)
        return MarkerReservation(id: id, rect: rect)
    }
}
