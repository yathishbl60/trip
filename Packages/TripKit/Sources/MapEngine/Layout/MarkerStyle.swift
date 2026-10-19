#if !TRIP_STANDALONE
import TripLocalization
#endif
import Foundation
import CoreGraphics

public nonisolated enum MarkerStyle: Int, Sendable, CaseIterable {
    case dot, thumbnail, card
    public var hasPhoto: Bool { self != .dot }
    public var hasLabel: Bool { self == .card }

    public var title: String {
        switch self {
        case .dot: TripText.dot.text
        case .thumbnail: TripText.iconImage.text
        case .card: TripText.view.text
        }
    }

    public var size: CGSize {
        switch self {
        case .dot: CGSize(width: 12, height: 12)
        case .thumbnail: CGSize(width: 44, height: 44)
        case .card: CGSize(width: 184, height: 64)
        }
    }

    public var photoSize: CGSize {
        switch self {
        case .thumbnail: CGSize(width: 38, height: 38)
        case .card: CGSize(width: 52, height: 52)
        case .dot: CGSize(width: 8, height: 8)
        }
    }

    public var photoRadius: CGFloat { photoSize.width / 2 }
    public var titleLines: Int { 2 }
    public var titleSize: CGFloat { 13 }

    public func hitSize(scale: CGFloat) -> CGSize {
        let minimum: CGFloat = self == .dot ? 28 : 44
        return CGSize(width: max(size.width * scale, minimum), height: max(size.height * scale, minimum))
    }
}
