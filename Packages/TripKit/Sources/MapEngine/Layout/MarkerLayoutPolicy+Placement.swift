import CoreGraphics

nonisolated extension MarkerLayoutPolicy {
    /// Screen-point padding around steady, shrinking, and retiring annotation touch bounds.
    public static let steadyClearance: CGFloat = 4
    /// Extra screen-point padding needed when an annotation enters or grows to a larger appearance.
    public static let entryAndPromotionClearance: CGFloat = 9

    /// Keep a few recognizable places even in a small viewport; collision checks still take precedence.
    func photoLimit(in viewport: CGRect) -> Int {
        let minimumRecognizablePlaces = 3
        let viewportArea = viewport.width * viewport.height
        return max(minimumRecognizablePlaces, Int(viewportArea / photoArea))
    }

    /// Growing or newly entering markers need more breathing room than steady or shrinking markers.
    func collisionClearance(for style: MarkerStyle, previous: MarkerStyle?) -> CGFloat {
        guard let previous else { return Self.entryAndPromotionClearance }
        let isGrowing = style.rawValue > previous.rawValue
        return isGrowing ? Self.entryAndPromotionClearance : Self.steadyClearance
    }

    /// Favor existing artwork, then weakly prefer the center so small pans do not reshuffle the map.
    func priority(importance: Double, distanceFromCenter: CGFloat, previousStyle: MarkerStyle?) -> Double {
        let artworkContinuityBonus = 0.35
        let dotContinuityBonus = 0.12
        let screenPointsPerImportanceUnit: CGFloat = 8_000
        let continuityBonus = previousStyle.map { $0.hasPhoto ? artworkContinuityBonus : dotContinuityBonus } ?? 0
        let finiteImportance = importance.isFinite ? importance : 0
        let centerPenalty = Double(distanceFromCenter / screenPointsPerImportanceUnit)
        return finiteImportance + continuityBonus - centerPenalty
    }
}
