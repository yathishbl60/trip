import SwiftUI

extension TripController {
    var stopOrder: Binding<TripStopOrderModel?> {
        let id = model.presentation.stopOrder?.id
        return Binding(get: { model.presentation.stopOrder }, set: { value in
            guard value == nil, model.presentation.stopOrder?.id == id else { return }
            model.presentation.stopOrder = nil
        })
    }

    func beginStopOrder(dayID: UUID, tripID: UUID) { model.beginStopOrder(dayID: dayID, tripID: tripID) }
    func applyStopOrder(_ draft: TripStopOrderModel) { model.applyStopOrder(draft) }
    func loadStopOrder(_ draft: TripStopOrderModel) async { await draft.load() }

    func closeStopOrder(_ id: UUID) {
        guard model.presentation.stopOrder?.id == id else { return }
        model.presentation.stopOrder = nil
    }

    func originalOrder(_ draft: TripStopOrderModel) -> Binding<Bool> {
        Binding(get: { draft.showsOriginal }, set: draft.showOriginal)
    }
}
