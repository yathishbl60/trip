import SwiftUI
import Testing
@testable import trip

@MainActor struct PlacePanelLayoutTests {
    @Test func shortWindowsExpandWithoutLosingThePreferredHeight() {
        let model = PlacePresentationModel()
        model.detent = PlacePresentationModel.compact
        model.usesCompactHeight = true
        #expect(model.detents == [.large] && model.detent == .large && !model.isCompact)
        model.usesCompactHeight = false
        #expect(model.detent == PlacePresentationModel.compact)
    }

    @Test func resultsAndLargeTextCannotCollapseIntoAnUnusablePanel() {
        let model = PlacePresentationModel()
        model.detent = PlacePresentationModel.compact
        model.allowsCompact = false
        #expect(!model.detents.contains(PlacePresentationModel.compact))
        #expect(model.detent == PlacePresentationModel.standard && !model.isCompact)
        model.usesLargeText = true
        #expect(model.detent == .fraction(0.75))
        model.detent = .large
        model.usesLargeText = false
        #expect(model.detent == .large)
    }
}
