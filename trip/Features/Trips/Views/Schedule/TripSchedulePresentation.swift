import SwiftUI

extension View {
    func tripScheduleSheets(_ controller: TripController) -> some View {
        sheet(item: controller.daySchedule) { draft in
            TripDayScheduleView(draft: draft, controller: controller)
        }
        .sheet(item: controller.stopTiming) { draft in
            TripStopTimingView(draft: draft, controller: controller)
        }
    }
}
