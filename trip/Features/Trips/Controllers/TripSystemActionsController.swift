import Foundation
import SwiftUI

@MainActor struct TripSystemActionsController {
    let model: TripSystemActionsModel

    var presentation: Binding<TripSystemActionSession?> {
        Binding(get: { model.presentation }, set: { if $0 == nil { model.dismiss() } })
    }

    func selected(_ id: String) -> Binding<Bool> {
        Binding(get: { model.presentation?.selectedIDs.contains(id) == true }, set: { model.select(id, included: $0) })
    }

    var usesDueDate: Binding<Bool> {
        Binding(get: { model.presentation?.usesDueDate == true }, set: { model.presentation?.usesDueDate = $0 })
    }

    var dueDate: Binding<Date> {
        Binding(get: { model.presentation?.dueDate ?? .now }, set: { model.presentation?.dueDate = $0 })
    }

    var alarmDate: Binding<Date> {
        Binding(get: { model.presentation?.alarmDate ?? .now }, set: { model.presentation?.alarmDate = $0 })
    }

    func perform() { model.perform() }
    func dismiss() { model.dismiss() }
    func cancelAlarm() { model.cancelAlarm() }
}
