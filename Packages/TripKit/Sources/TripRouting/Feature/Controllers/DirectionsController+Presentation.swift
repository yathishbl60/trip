#if os(iOS) || os(visionOS)
import SwiftUI

extension DirectionsController {
    var detent: Binding<PresentationDetent> {
        Binding(get: { model.presentation.detent }, set: { model.presentation.detent = $0 })
    }

    var readingSteps: Binding<Bool> {
        let visit = model.presentation.stepsVisit
        return Binding(get: { model.presentation.stepsVisit != nil }, set: { shown in
            if !shown, model.presentation.stepsVisit == visit { model.presentation.stepsVisit = nil }
        })
    }

    var editingRoute: Binding<Bool> {
        let id = model.presentation.auxiliary?.id
        return Binding(get: {
            guard let screen = model.presentation.auxiliary?.screen else { return false }
            return screen != .options
        }, set: { shown in
            guard !shown, model.presentation.auxiliary?.id == id else { return }
            model.dismissAuxiliary()
        })
    }

    var options: Binding<Bool> {
        let id = model.presentation.auxiliary?.id
        return Binding(get: { model.presentation.auxiliary?.screen == .options }, set: { shown in
            guard !shown, model.presentation.auxiliary?.id == id else { return }
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

    func sheetFrameChanged(_ measurement: DirectionsPanelMeasurement) {
        guard model.isPresented, model.destinationID == measurement.destinationID,
              model.presentation.session == measurement.session else { return }
        model.environment.sheetFrameChanged(measurement.frame)
    }

    func accessibility(largeText: Bool, reduceMotion: Bool) {
        model.presentation.usesLargeText = largeText
        model.presentation.reduceMotion = reduceMotion
    }
}
#endif
