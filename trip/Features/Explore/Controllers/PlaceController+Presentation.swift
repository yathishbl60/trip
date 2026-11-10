import SwiftUI
import TripDomain

extension PlaceController {
    var detailDetent: Binding<PresentationDetent> {
        let revision = model.selection.revision
        return Binding(get: { model.selection.presentation.detent }, set: { detent in
            guard model.selection.revision == revision else { return }
            model.selection.presentation.detent = detent
        })
    }

    var allowsCollapsedDetails: Bool {
        model.selectedPlace != nil && !model.browse.isPresented && model.selection.detailPath.isEmpty
    }

    func updatePanelLayout(_ layout: PlacePanelLayout) {
        model.selection.presentation.usesLargeText = layout.largeText
        model.selection.presentation.usesCompactHeight = layout.compactHeight
        model.selection.presentation.allowsCompact = layout.allowsCompact
    }
}
