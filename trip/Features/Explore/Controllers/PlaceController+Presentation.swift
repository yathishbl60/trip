import SwiftUI

extension PlaceController {
    var detailDetent: Binding<PresentationDetent> {
        let revision = model.selection.revision
        return Binding(get: { model.selection.presentation.detent }, set: { detent in
            guard model.selection.revision == revision else { return }
            model.selection.presentation.detent = detent
        })
    }

    func detailAccessibilityChanged(_ typeSize: DynamicTypeSize) {
        model.selection.presentation.usesLargeText = typeSize.isAccessibilitySize
    }
}
