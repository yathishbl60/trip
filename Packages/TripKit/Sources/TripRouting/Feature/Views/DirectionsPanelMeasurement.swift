#if os(iOS) || os(visionOS)
import SwiftUI

nonisolated struct DirectionsPanelMeasurement: Equatable, Sendable {
    let frame: CGRect
    let destinationID: String?
    let session: Int
}

extension View {
    @MainActor func reportingDirectionsFrame(to controller: DirectionsController) -> some View {
        let destinationID = controller.model.destinationID
        let session = controller.model.presentation.session
        return onGeometryChange(for: DirectionsPanelMeasurement.self) { geometry in
            DirectionsPanelMeasurement(frame: geometry.frame(in: .global), destinationID: destinationID, session: session)
        } action: { measurement in
            controller.sheetFrameChanged(measurement)
        }
    }
}
#endif
