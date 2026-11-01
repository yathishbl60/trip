import SwiftUI
import TripDomain
import TripDomain
import TripLocalization

struct TripCalendarExportFields: View {
    let session: TripSystemActionSession
    let controller: TripSystemActionsController

    var body: some View {
        Section {
            if session.bookings.isEmpty {
                ContentUnavailableView(TripText.noCalendarBookings.resource, systemImage: "calendar",
                                       description: Text(TripText.calendarEligibleOnly.resource))
            }
            ForEach(session.bookings) { booking in bookingRow(booking) }
        } footer: { Text(TripText.calendarExportExplanation.resource) }
    }

    private func bookingRow(_ booking: TripSystemBooking) -> some View {
        Toggle(isOn: controller.selected(booking.id)) {
            VStack(alignment: .leading) {
                Text(booking.title)
                Text(controller.model.summary(for: booking)).font(.caption).foregroundStyle(.secondary)
                Text(booking.timeZoneID).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

#if DEBUG
#Preview("Calendar selection · local data") {
    let model = PreviewSystemActions.model(.calendar)
    Form { TripCalendarExportFields(session: model.presentation!, controller: TripSystemActionsController(model: model)) }
}
#endif
