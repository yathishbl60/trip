import CoreGraphics

public extension MarkerStyle {
    static let captionSpacing: CGFloat = 3
    static let metadataHeight: CGFloat = 14
    static var captionTitleHeight: CGFloat { card.contentHeight - captionSpacing - metadataHeight }

    var contentInset: CGFloat {
        switch self {
        case .dot: 2
        case .thumbnail: 3
        case .card: 6
        }
    }

    var contentSpacing: CGFloat { hasLabel ? 10 : 0 }
    var contentHeight: CGFloat { size.height - contentInset * 2 }
    var captionWidth: CGFloat { max(0, size.width - contentInset * 2 - photoSize.width - contentSpacing) }
    var photoOpacity: Double { hasPhoto ? 1 : 0 }
    var labelOpacity: Double { hasLabel ? 1 : 0 }
    var badgeOpacity: Double { hasPhoto ? 1 : 0 }
    var surfaceRadius: CGFloat { self == .card ? 20 : size.height / 2 }
    var shadowRadius: CGFloat { hasLabel ? 4 : 2 }
    var shadowOffset: CGFloat { hasLabel ? 2 : 1 }
}
