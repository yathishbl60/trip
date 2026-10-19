#if os(iOS) || os(visionOS)
import SwiftUI

extension DirectionsController {
    var detent: Binding<PresentationDetent> {
        Binding(get: { model.presentation.detent }, set: { model.presentation.detent = $0 })
    }

    var auxiliary: Binding<DirectionsAuxiliary?> {
        let id = model.presentation.auxiliary?.id
        return Binding(get: { model.presentation.auxiliary }, set: { value in
            guard value == nil, model.presentation.auxiliary?.id == id else { return }
            model.dismissAuxiliary()
        })
    }

    var choosingPlace: Binding<Bool> {
        let id = model.presentation.placePicker?.id
        return Binding(get: {
            model.presentation.auxiliary?.screen == .stops && model.presentation.placePicker != nil
        }, set: { value in
            if !value, model.presentation.placePicker?.id == id { model.closePlacePicker() }
        })
    }

    func sheetFrameChanged(_ frame: CGRect) { model.environment.sheetFrameChanged(frame) }
    func accessibility(largeText: Bool, reduceMotion: Bool, compactHeight: Bool, regularWidth: Bool) {
        model.presentation.accessibility(largeText: largeText, reduceMotion: reduceMotion,
                                        compactHeight: compactHeight, regularWidth: regularWidth)
    }
}
#endif
